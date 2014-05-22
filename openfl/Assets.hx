package openfl;
#if !macro


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.Lib;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.text.Font;
import flash.utils.ByteArray;
import haxe.Unserializer;


/**
 * <p>The Assets class provides a cross-platform interface to access 
 * embedded images, fonts, sounds and other resource files.</p>
 * 
 * <p>The contents are populated automatically when an application
 * is compiled using the OpenFL command-line tools, based on the
 * contents of the *.nmml project file.</p>
 * 
 * <p>For most platforms, the assets are included in the same directory
 * or package as the application, and the paths are handled
 * automatically. For web content, the assets are preloaded before
 * the start of the rest of the application. You can customize the 
 * preloader by extending the <code>NMEPreloader</code> class,
 * and specifying a custom preloader using <window preloader="" />
 * in the project file.</p>
 */
@:access(openfl.AssetLibrary) class Assets {
	
	
	public static var cache:AssetCache = new AssetCache ();
	public static var libraries (default, null) = new Map <String, AssetLibrary> ();
	
	private static var initialized = false;
	
	
	public static function exists (id:String, type:AssetType = null):Bool {
		
		initialize ();
		
		#if (tools && !display)
		
		if (type == null) {
			
			type = BINARY;
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			return library.exists (symbolName, type);
			
		}
		
		#end
		
		return false;
		
	}
	
	
	/**
	 * Gets an instance of an embedded bitmap
	 * @usage	var bitmap = new Bitmap(Assets.getBitmapData("image.jpg"));
	 * @param	id	The ID or asset path for the bitmap
	 * @param	useCache	(Optional) Whether to use BitmapData from the cache(Default: true)
	 * @return	A new BitmapData object
	 */
	public static function getBitmapData (id:String, useCache:Bool = true):BitmapData {
		initialize ();
		#if (tools && !display)
		var c:AssetCache, r:BitmapData,
			i:Int, ln:String, sn:String, lr:AssetLibrary;
		// pick up from cache, if possible:
		if (useCache && (c = cache).enabled && c.bitmapData.exists(id)
		&& isValidBitmapData(r = cache.bitmapData.get(id))) return r;
		// pick up library & symbol names:
		i = id.indexOf(":");
		ln = id.substring(0, i);
		sn = id.substr(i + 1);
		lr = getLibrary(ln);
		// the quite so cautious approach to getting a bitmap:
		if (lr != null) {
			if (lr.exists(sn, IMAGE)) {
				r = lr.getBitmapData(sn);
				if (useCache) {
					if (c.enabled) c.bitmapData.set(id, r);
				} else r = r.clone();
				return r;
			} else Lib.trace('[openfl.Assets] There is no BitmapData asset with an ID of "$sn"');
		} else Lib.trace('[openfl.Assets] There is no asset library named "$ln"');
		#end
		return null;
	}
	
	
	/**
	 * Gets an instance of an embedded binary asset
	 * @usage		var bytes = Assets.getBytes("file.zip");
	 * @param	id		The ID or asset path for the file
	 * @return		A new ByteArray object
	 */
	public static function getBytes (id:String):ByteArray {
		
		initialize ();
		
		#if (tools && !display)
		
		var libraryName = id.substring (0, id.indexOf(":"));
		var symbolName = id.substr (id.indexOf(":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, BINARY)) {
				
				if (library.isLocal (symbolName, BINARY)) {
					
					return library.getBytes (symbolName);
					
				} else {
					
					trace ("[openfl.Assets] String or ByteArray asset \"" + id + "\" exists, but only asynchronously");
					
				}
				
			} else {
				
				trace ("[openfl.Assets] There is no String or ByteArray asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	/**
	 * Gets an instance of an embedded font
	 * @usage		var fontName = Assets.getFont("font.ttf").fontName;
	 * @param	id		The ID or asset path for the font
	 * @return		A new Font object
	 */
	public static function getFont (id:String, useCache:Bool = true):Font {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled && cache.font.exists (id)) {
			
			return cache.font.get (id);
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, FONT)) {
				
				if (library.isLocal (symbolName, FONT)) {
					
					var font = library.getFont (symbolName);
					
					if (useCache && cache.enabled) {
						
						cache.font.set (id, font);
						
					}
					
					return font;
					
				} else {
					
					trace ("[openfl.Assets] Font asset \"" + id + "\" exists, but only asynchronously");
					
				}
				
			} else {
				
				trace ("[openfl.Assets] There is no Font asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	private static function getLibrary (name:String):AssetLibrary {
		
		if (name == null || name == "") {
			
			name = "default";
			
		}
		
		return libraries.get (name);
		
	}
	
	
	/**
	 * Gets an instance of a library MovieClip
	 * @usage		var movieClip = Assets.getMovieClip("library:BouncingBall");
	 * @param	id		The library and ID for the MovieClip
	 * @return		A new Sound object
	 */
	public static function getMovieClip (id:String):MovieClip {
		
		initialize ();
		
		#if (tools && !display)
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, MOVIE_CLIP)) {
				
				if (library.isLocal (symbolName, MOVIE_CLIP)) {
					
					return library.getMovieClip (symbolName);
					
				} else {
					
					trace ("[openfl.Assets] MovieClip asset \"" + id + "\" exists, but only asynchronously");
					
				}
				
			} else {
				
				trace ("[openfl.Assets] There is no MovieClip asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	/**
	 * Gets an instance of an embedded streaming sound
	 * @usage		var sound = Assets.getMusic("sound.ogg");
	 * @param	id		The ID or asset path for the music track
	 * @return		A new Sound object
	 */
	public static function getMusic (id:String, useCache:Bool = true):Sound {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			
			var sound = cache.sound.get (id);
			
			if (isValidSound (sound)) {
				
				return sound;
				
			}
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, MUSIC)) {
				
				if (library.isLocal (symbolName, MUSIC)) {
					
					var sound = library.getMusic (symbolName);
					
					if (useCache && cache.enabled) {
						
						cache.sound.set (id, sound);
						
					}
					
					return sound;
					
				} else {
					
					trace ("[openfl.Assets] Sound asset \"" + id + "\" exists, but only asynchronously");
					
				}
				
			} else {
				
				trace ("[openfl.Assets] There is no Sound asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	/**
	 * Gets the file path (if available) for an asset
	 * @usage		var path = Assets.getPath("image.jpg");
	 * @param	id		The ID or asset path for the asset
	 * @return		The path to the asset (or null)
	 */
	public static function getPath (id:String):String {
		
		initialize ();
		
		#if (tools && !display)
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, null)) {
				
				return library.getPath (symbolName);
				
			} else {
				
				trace ("[openfl.Assets] There is no asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	/**
	 * Gets an instance of an embedded sound
	 * @usage		var sound = Assets.getSound("sound.wav");
	 * @param	id		The ID or asset path for the sound
	 * @return		A new Sound object
	 */
	public static function getSound (id:String, useCache:Bool = true):Sound {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			
			var sound = cache.sound.get (id);
			
			if (isValidSound (sound)) {
				
				return sound;
				
			}
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, SOUND)) {
				
				if (library.isLocal (symbolName, SOUND)) {
					
					var sound = library.getSound (symbolName);
					
					if (useCache && cache.enabled) {
						
						cache.sound.set (id, sound);
						
					}
					
					return sound;
					
				} else {
					
					trace ("[openfl.Assets] Sound asset \"" + id + "\" exists, but only asynchronously");
					
				}
				
			} else {
				
				trace ("[openfl.Assets] There is no Sound asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	/**
	 * Gets an instance of an embedded text asset
	 * @usage		var text = Assets.getText("text.txt");
	 * @param	id		The ID or asset path for the file
	 * @return		A new String object
	 */
	public static function getText (id:String):String {
		
		var bytes = getBytes (id);
		
		if (bytes == null) {
			
			return null;
			
		} else {
			
			return bytes.readUTFBytes (bytes.length);
			
		}
		
	}
	
	
	private static function initialize ():Void {
		
		if (!initialized) {
			
			#if (tools && !display)
			
			registerLibrary ("default", new DefaultAssetLibrary ());
			
			#end
			
			initialized = true;
			
		}
		
	}
	
	
	public static function isLocal (id:String, type:AssetType = null, useCache:Bool = true):Bool {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled) {
			
			if (type == AssetType.IMAGE || type == null) {
				
				if (cache.bitmapData.exists (id)) return true;
				
			}
			
			if (type == AssetType.FONT || type == null) {
				
				if (cache.font.exists (id)) return true;
				
			}
			
			if (type == AssetType.SOUND || type == AssetType.MUSIC || type == null) {
				
				if (cache.sound.exists (id)) return true;
				
			}
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			return library.isLocal (symbolName, type);
			
		}
		
		#end
		
		return false;
		
	}
	
	
	private static function isValidBitmapData (bitmapData:BitmapData):Bool {
		
		#if (cpp || neko)
		
		return (bitmapData.__handle != null);
		
		#elseif flash
		
		try {
			
			bitmapData.width;
			
		} catch (e:Dynamic) {
			
			return false;
			
		}
		
		#end
		
		return true;
		
	}
	
	
	private static function isValidSound (sound:Sound):Bool {
		
		#if (cpp || neko)
		
		return (sound.__handle != null && sound.__handle != 0);
		
		#else
		
		return true;
		
		#end
		
	}
	
	
	public static function loadBitmapData (id:String, handler:BitmapData -> Void, useCache:Bool = true):Void {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled && cache.bitmapData.exists (id)) {
			
			var bitmapData = cache.bitmapData.get (id);
			
			if (isValidBitmapData (bitmapData)) {
				
				handler (bitmapData);
				return;
				
			}
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, IMAGE)) {
				
				if (useCache && cache.enabled) {
					
					library.loadBitmapData (symbolName, function (bitmapData:BitmapData):Void {
						
						cache.bitmapData.set (id, bitmapData);
						handler (bitmapData);
						
					});
					
				} else {
					
					library.loadBitmapData (symbolName, handler);
					
				}
				
				return;
				
			} else {
				
				trace ("[openfl.Assets] There is no BitmapData asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		handler (null);
		
	}
	
	
	public static function loadBytes (id:String, handler:ByteArray -> Void):Void {
		
		initialize ();
		
		#if (tools && !display)
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, BINARY)) {
				
				library.loadBytes (symbolName, handler);
				return;
				
			} else {
				
				trace ("[openfl.Assets] There is no String or ByteArray asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		handler (null);
		
	}
	
	
	public static function loadFont (id:String, handler:Font -> Void, useCache:Bool = true):Void {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled && cache.font.exists (id)) {
			
			handler (cache.font.get (id));
			return;
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, FONT)) {
				
				if (useCache && cache.enabled) {
					
					library.loadFont (symbolName, function (font:Font):Void {
						
						cache.font.set (id, font);
						handler (font);
						
					});
					
				} else {
					
					library.loadFont (symbolName, handler);
					
				}
				
				return;
				
			} else {
				
				trace ("[openfl.Assets] There is no Font asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		handler (null);
		
	}
	
	
	public static function loadLibrary (name:String, handler:AssetLibrary -> Void):Void {
		
		initialize();
		
		#if (tools && !display)
		
		var data = getText ("libraries/" + name + ".dat");
		
		if (data != null && data != "") {
			
			var unserializer = new Unserializer (data);
			unserializer.setResolver (cast { resolveEnum: resolveEnum, resolveClass: resolveClass });
			
			var library:AssetLibrary = unserializer.unserialize ();
			libraries.set (name, library);
			library.load (handler);
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + name + "\"");
			
		}
		
		#end
		
	}
	
	
	public static function loadMusic (id:String, handler:Sound -> Void, useCache:Bool = true):Void {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			
			var sound = cache.sound.get (id);
			
			if (isValidSound (sound)) {
				
				handler (sound);
				return;
				
			}
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, MUSIC)) {
				
				if (useCache && cache.enabled) {
					
					library.loadMusic (symbolName, function (sound:Sound):Void {
						
						cache.sound.set (id, sound);
						handler (sound);
						
					});
					
				} else {
					
					library.loadMusic (symbolName, handler);
					
				}
				
				return;
				
			} else {
				
				trace ("[openfl.Assets] There is no Sound asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		handler (null);
		
	}
	
	
	public static function loadMovieClip (id:String, handler:MovieClip -> Void):Void {
		
		initialize ();
		
		#if (tools && !display)
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, MOVIE_CLIP)) {
				
				library.loadMovieClip (symbolName, handler);
				return;
				
			} else {
				
				trace ("[openfl.Assets] There is no MovieClip asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		handler (null);
		
	}
	
	
	public static function loadSound (id:String, handler:Sound -> Void, useCache:Bool = true):Void {
		
		initialize ();
		
		#if (tools && !display)
		
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			
			var sound = cache.sound.get (id);
			
			if (isValidSound (sound)) {
				
				handler (sound);
				return;
				
			}
			
		}
		
		var libraryName = id.substring (0, id.indexOf (":"));
		var symbolName = id.substr (id.indexOf (":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			if (library.exists (symbolName, SOUND)) {
				
				if (useCache && cache.enabled) {
					
					library.loadSound (symbolName, function (sound:Sound):Void {
						
						cache.sound.set (id, sound);
						handler (sound);
						
					});
					
				} else {
					
					library.loadSound (symbolName, handler);
					
				}
				
				return;
				
			} else {
				
				trace ("[openfl.Assets] There is no Sound asset with an ID of \"" + id + "\"");
				
			}
			
		} else {
			
			trace ("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		handler (null);
		
	}
	
	
	public static function loadText (id:String, handler:String -> Void):Void {
		
		initialize ();
		
		#if (tools && !display)
		
		var callback = function (bytes:ByteArray):Void {
			
			if (bytes == null) {
				
				handler (null);
				
			} else {
				
				handler (bytes.readUTFBytes (bytes.length));
				
			}
			
		}
		
		loadBytes (id, callback);
		
		#else
		
		handler (null);
		
		#end
		
	}
	
	
	public static function registerLibrary (name:String, library:AssetLibrary):Void {
		
		if (libraries.exists (name)) {
			
			unloadLibrary (name);
			
		}
		
		libraries.set (name, library);
		
	}
	
	
	private static function resolveClass (name:String):Class <Dynamic> {
		
		return Type.resolveClass (name);
		
	}
	
	
	private static function resolveEnum (name:String):Enum <Dynamic> {
		
		var value = Type.resolveEnum (name);
		
		#if flash
		
		if (value == null) {
			
			return cast Type.resolveClass (name);
			
		}
		
		#end
		
		return value;
		
	}
	
	
	public static function unloadLibrary (name:String):Void {
		
		initialize();
		
		#if (tools && !display)
		
		var keys = cache.bitmapData.keys ();
		
		for (key in keys) {
			
			var libraryName = key.substring (0, key.indexOf (":"));
			var symbolName = key.substr (key.indexOf (":") + 1);
			
			if (libraryName == name) {
				
				cache.bitmapData.remove (key);
				
			}
			
		}
		
		libraries.remove (name);
		
		#end
		
	}
}


class AssetLibrary {
	public function new() { }
	public function exists(id:String, type:AssetType):Bool return false;
	public function getBitmapData(id:String):BitmapData return null;
	public function getBytes(id:String):ByteArray return null;
	public function getText(id:String):String return null;
	public function getFont(id:String):Font return null;
	public function getMovieClip(id:String):MovieClip return null;
	public function getMusic(id:String):Sound return getSound (id);
	public function getPath(id:String):String return null;
	public function getSound(id:String):Sound return null;
	public function isLocal(id:String, type:AssetType):Bool return true;
	//
	private function load(h:AssetLibrary->Void):Void h(this);
	public function loadBitmapData(id:String, h:BitmapData->Void):Void h(getBitmapData(id));
	public function loadBytes(id:String, h:ByteArray->Void):Void h(getBytes(id));
	public function loadText(id:String, h:String->Void):Void h(getText(id));
	public function loadFont(id:String, h:Font->Void):Void h(getFont(id));
	public function loadMovieClip(id:String, h:MovieClip->Void):Void h(getMovieClip(id));
	public function loadMusic(id:String, handler:Sound->Void):Void handler(getMusic(id));
	public function loadSound(id:String, handler:Sound->Void):Void handler(getSound(id));
}


class AssetCache {
	
	
	public var bitmapData:Map<String, BitmapData>;
	public var enabled:Bool = true;
	public var font:Map<String, Font>;
	public var sound:Map<String, Sound>;
	
	
	public function new () {
		
		bitmapData = new Map<String, BitmapData> ();
		font = new Map<String, Font> ();
		sound = new Map<String, Sound> ();
		
	}
	
	
	public function clear ():Void {
		
		bitmapData = new Map<String, BitmapData> ();
		font = new Map<String, Font> ();
		sound = new Map<String, Sound> ();
		
	}
	
	
}


class AssetData {
	
	
	public var id:String;
	public var path:String;
	public var type:AssetType;
	
	public function new () {
		
		
		
	}
	
	
}


enum AssetType {
	
	BINARY;
	FONT;
	IMAGE;
	MOVIE_CLIP;
	MUSIC;
	SOUND;
	TEMPLATE;
	TEXT;
	
}


#else // start macro:


import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.Serializer;
import sys.io.File;


class Assets {
	/// handles flash.display.BitmapData metadata
	macro public static function embedBitmap ():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields(),
			path:String = getMeta(":bitmap"),
			mpos:Position = null,
			b64:String = null;
		if (path != null) {
			mpos = getMetaPos(":bitmap");
			var data:Bytes = getBytes(path);
			if (data != null) {
				b64 = "data:image/" + getExtension(path) + ";base64," + toBase64(data);
			} else Context.warning("Failed to load " + path, mpos);
		}
		if (path != null) {
			// private static var image:ImageElement;
			fields.push({
				name: "image",
				access: [APrivate, AStatic],
				kind: FVar(macro:js.html.ImageElement),
				pos: mpos
			});
			// private static function preload():Void (image = ..).src = "data:image/...";
			fields.push({
				name: "preload",
				access: [APrivate, AStatic],
				kind: FFun({
					args: [],
					ret: null,
					expr: macro {
						var o:js.html.Image = untyped document.createElement("img");
						ApplicationMain.loadEmbed(o);
						o.src = $v{b64};
						image = o;
					}, params: []
				}), pos: mpos
			});
			// private static function __init__():Void preload();
			fields.push({
				name: "__init__",
				access: [APrivate, AStatic],
				kind: FFun({
					args: [],
					ret: null,
					expr: macro {
						preload();
					}, params: []
				}), pos: mpos
			});
			/* public function new():Void {
				 * var o:ImageElement = image;
				 * super(o.width, o.height, true, 0);
				 * qContext.drawImage(o, 0, 0);
			 * }
			 */
			fields.push({
				name: "new",
				access: [APublic],
				kind: FFun({
					args: [
						makeArg("width", macro:Int, false),
						makeArg("height", macro:Int, false),
						makeArg("transparent", macro:Bool, true),
						makeArg("color", macro:Int, true),
					], ret: null,
					expr: macro {
						var o:js.html.ImageElement = image;
						super(o.width, o.height, true, 0);
						qContext.drawImage(o, 0, 0);
					}, params: []
				}), pos: mpos
			});	
		}
		
		return fields;
		
	}
	
	/// Creates a FunctionArg typedef.
	private static function makeArg(o:String, ?t:ComplexType, z:Bool = true, ?v:Expr):FunctionArg {
		return { name: o, opt: z, type: t, value: v };
	}
	
	/// Returns file contents as haxe.io.Bytes (or null if it does not exist)
	private static function getBytes(p:String):Bytes {
		try {
			return File.getBytes(Context.resolvePath(p));
		} catch (_:Dynamic) { return null; }
	}
	
	/// Returns file extension (without preceding dot)
	private static function getExtension(p:String):String {
		var i:Int = p.lastIndexOf(".");
		return i >= 0 ? p.substring(i + 1) : "";
	}
	
	/// 
	private static function getMeta(o:String):String {
		for (v in Context.getLocalClass().get().meta.get())
		if (v.name == o && v.params.length > 0)
		switch (v.params[0].expr) {
		case EConst(CString(r)): return r;
		default:
		}
		return null;
	}
	
	///
	private static function getMetaPos(o:String):Position {
		for (v in Context.getLocalClass().get().meta.get())
		if (v.name == o && v.params.length > 0)
		return v.params[0].pos;
		return Context.currentPos();
	}
	
	/// Converts haxe.io.Bytes contents to URI-compliant base64 string.
	private static function toBase64(d:Bytes):String {
		var r:String, s:Serializer = new Serializer();
		s.serialize(d);
		r = s.toString();
		r = r.substring(r.indexOf(":") + 1);
		r = StringTools.replace(r, ":", "/");
		r = StringTools.replace(r, "%", "+");
		return r;
	}
	
	
	private static function embedData (metaName:String):Array<Field> {
		
		var classType = Context.getLocalClass().get();
		var metaData = classType.meta.get();
		var position = Context.currentPos();
		var fields = Context.getBuildFields();
		
		for (meta in metaData)
		if (meta.name == metaName && meta.params.length > 0)
		switch (meta.params[0].expr) {
		case EConst(CString(filePath)):
			
			var path = Context.resolvePath (filePath);
			var bytes = File.getBytes (path);
			var resourceName = "__ASSET__" + metaName + "_" + (classType.pack.length > 0 ? classType.pack.join ("_") + "_" : "") + classType.name;
			
			Context.addResource (resourceName, bytes);
			
			var fieldValue = {
				pos: position,
				expr: EConst(CString(resourceName))
			};
			fields.push( {
				kind: FVar(macro:String, fieldValue),
				name: "resourceName",
				access: [ APrivate, AStatic ],
				pos: position
			});
			
			return fields;
			
		default:
			
		}
		return null;
		
	}
	
	
	macro public static function embedFile ():Array<Field> {
		
		var fields = embedData (":file");
		
		if (fields != null) {
			
			var constructor = macro { 
				
				super();
				
				#if html5
				nmeFromBytes (haxe.Resource.getBytes (resourceName));
				#else
				__fromBytes (haxe.Resource.getBytes (resourceName));
				#end
				
			};
			
			var args = [ { name: "size", opt: true, type: macro :Int, value: macro 0 } ];
			fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: args, expr: constructor, params: [], ret: null }), pos: Context.currentPos() });
			
		}
		return fields;
		
	}
	
	
	macro public static function embedFont():Array<Field> {
		// Doesn't work like that.
		var fields = null;
		Context.warning("Embed fonts are not supported", Context.currentPos());
		return fields;
		
	}
	
	
	macro public static function embedSound ():Array<Field> {
		
		var fields = embedData (":sound");
		
		if (fields != null) {
			
			#if (!html5) // CFFILoader.h(248) : NOT Implemented:api_buffer_data
			
			var constructor = macro { 
				
				super();
				
				var byteArray = flash.utils.ByteArray.fromBytes (haxe.Resource.getBytes(resourceName));
				loadCompressedDataFromByteArray(byteArray, byteArray.length, forcePlayAsMusic);
				
			};
			
			var args = [ { name: "stream", opt: true, type: macro :flash.net.URLRequest, value: null }, { name: "context", opt: true, type: macro :flash.media.SoundLoaderContext, value: null }, { name: "forcePlayAsMusic", opt: true, type: macro :Bool, value: macro false } ];
			fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: args, expr: constructor, params: [], ret: null }), pos: Context.currentPos() });
			
			#end
			
		}
		
		return fields;
		
	}
	
	
}


#end
