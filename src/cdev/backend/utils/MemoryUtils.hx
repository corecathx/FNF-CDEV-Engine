package cdev.backend.utils;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;

using StringTools;

class MemoryUtils {
    public static function clear(?major:Bool = false) {
        if (major) {
            #if cpp
            Gc.run(true);
            Gc.compact();
            #elseif hl
            Gc.major();
            #elseif (java || neko)
            Gc.run(true);
            #end
        } else {
            #if (cpp || java || neko)
            Gc.run(false);
            #end
        }
    }

	public static inline function usedMemory() {
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#elseif hl
		return Gc.stats().currentMemory;
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}
}