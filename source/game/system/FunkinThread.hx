package game.system;

import sys.thread.Mutex;
import flixel.math.FlxMath;
import sys.thread.FixedThreadPool;


class FunkinThread {

	/**
	 * Runs a list of tasks based of `taskList`.
	 */
    public static function doTask(taskList:Array<() -> Void>,onTaskChange:(Int)->Void, onTaskFinished:()->Void, ?onFailed:(String)->Void) {
        var cTasks:Int = 0;
        var threadPool:FixedThreadPool = new FixedThreadPool(taskList.length);

        trace("Thread Pool created: " + threadPool.threadsCount);

        var mtx:Mutex = new Mutex();
        for (task in taskList){
            threadPool.run(() -> {
                try {
                    task();
    
                    mtx.acquire();
                    cTasks++;
                    mtx.release();
    
                    onTaskChange(cTasks);
    
                    if (cTasks >= threadPool.threadsCount){
                        onTaskFinished();
                        threadPool.shutdown();
                    }              
                } catch(e) {
                    onFailed("[FunkinThread] Failed to run task, " + e.toString());
                    Log.warn("[FunkinThread] Failed to run task, " + e.toString());
                }
            });
        }
    }
}