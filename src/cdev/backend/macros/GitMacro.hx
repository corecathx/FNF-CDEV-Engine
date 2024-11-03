package cdev.backend.macros;

#if macro
import sys.io.Process;
#end
import haxe.macro.Expr;

class GitMacro {
    public static macro function getCommitHash() {
        #if macro
        try {
			var proc = new Process('git', ['rev-parse', '--short', 'HEAD'], false);
			proc.exitCode(true);
			return macro $v{proc.stdout.readLine()};
		} catch(e)
            Sys.println('Error occured getting git commit hash: ' + e);
        
        return macro $v{"-"};
        #else
        return macro $v{"-"};
        #end
    }

    public static macro function getCommitNumber() {
        #if macro
        try {
			var proc = new Process('git', ['rev-list', 'HEAD', '--count'], false);
			proc.exitCode(true);
			return macro $v{Std.parseInt(proc.stdout.readLine())};
		} catch(e)
            Sys.println('Error occured getting git commit hash: ' + e);
        
        return macro $v{0};
        #else
        return macro $v{0};
        #end
    }
    public static macro function getGitBranch() {
        var branchName:String = "unknown";
        #if macro
        try {
            var pos = haxe.macro.Context.currentPos();
            var branchProcess = new sys.io.Process('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
        
            if (branchProcess.exitCode() != 0)
            {
                var message = branchProcess.stderr.readAll().toString();
                haxe.macro.Context.info('[WARN] Could not determine current git commit; is this a proper Git repository?', pos);
            }
        
            branchName = branchProcess.stdout.readLine();
            branchProcess.close();
        } catch (e) {
            Sys.println("Couldn't get Git Branch.");
        }
        #end
        return macro $v{branchName};
    }
      
}