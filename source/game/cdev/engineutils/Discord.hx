package game.cdev.engineutils;

import game.cdev.CDevUtils.DiscordJson;
import game.cdev.CDevConfig;
import Sys.sleep;
#if DISCORD_RPC
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordClient
{
	public static var initialized:Bool = false;
	public static var RPC_DATA:DiscordJson = null;
	public static var error:Bool = false;
	#if DISCORD_RPC
	public function new()
	{
		RPC_DATA = CDevConfig.utils.getRpcJSON();
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: (RPC_DATA != null ? RPC_DATA.clientID : CDevConfig.RPC_ID),
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			if (error) return;
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: RPC_DATA.imageKey,
			largeImageText: RPC_DATA.imageTxt
		});
	}

	static function onError(_code:Int, _message:String)
	{
		error = true;
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		if (initialized) return;
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		initialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		if (!Main.discordRPC) return;
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		var largeImgtxt:String = 'CDEV Engine v.' + CDevConfig.engineVersion;
		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: largeImgtxt,
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
	#else
	//balls
	public function new(){}

	public static function shutdown(){}

	static function onReady(){}

	static function onError(_code:Int, _message:String){}

	static function onDisconnected(_code:Int, _message:String){}

	public static function initialize(){}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float){}
	#end
}
