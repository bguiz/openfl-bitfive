package flash.text;
#if js
import flash.display.IBitmapDrawable;
import flash.Lib;
import js.html.DivElement;
import js.html.Element;
import js.html.TextAreaElement;
/**
 * Status: Implementation pending.
 * Included solely to avoid infinite errors.
 */
class TextField extends flash.display.InteractiveObject implements IBitmapDrawable {
	public var autoSize(default, set):String;
	public var antiAliasType:AntiAliasType;
	public var background(get, set):Bool;
	public var backgroundColor(default, set):Int = 0xffffff;
	public var border(get, set):Bool;
	public var borderColor(default, set):Int = 0x0;
	public var caretIndex(default, null):Int;
	public var defaultTextFormat:TextFormat;
	public var displayAsPassword:Bool;
	public var embedFonts:Bool;
	public var htmlText:String;
	public var length(default, null):Int;
	public var maxChars(default, set):Int = 0;
	public var multiline(default, set):Bool;
	public var scrollV:Int;
	public var maxScrollV:Int;
	public var numLines(get, null):Int;
	public var selectable(default, set):Bool;
	public var selectedText(get, null):String;
	public var selectionBeginIndex(get, set):Int;
	public var selectionEndIndex(get, set):Int;
	public var styleSheet:Dynamic;
	public var text(get, set):String;
	public var textColor:Int;
	public var textHeight(get, null):Float;
	public var textWidth(get, null):Float;
	public var type(default, set):String = "DYNAMIC";
	public var wordWrap:Bool;
	//
	private var qText:String = "";
	private var qFontStyle:String;
	private var qLineHeight:Float;
	private var qTextArea:TextAreaElement;
	private var qEditable:Bool;
	private var qBackground:Bool;
	private var qBorder:Bool;
	//
	public function new() {
		super();
		var s = component.style;
		s.whiteSpace = "nowrap";
		s.overflow = "hidden";
		//
		defaultTextFormat = new TextFormat("_serif", 16, 0);
		textColor = 0;
		wordWrap = qEditable = qBackground = qBorder = false;
		width = height = 100;
	}
	// Apperance
	private function get_background() return qBackground;
	private function set_background(v:Bool) {
		if (qBackground != v) {
			if (qBackground = v) this.component.style.background = Lib.rgbf(backgroundColor, 1);
		}
		return v;
	}
	private function set_backgroundColor(v:Int) {
		if (backgroundColor != v) {
			backgroundColor = v;
			if (qBackground) this.component.style.background = Lib.rgbf(v, 1);
		}
		return v;
	}
	private function get_border() return qBorder;
	private function set_border(v:Bool) {
		if (qBorder != v) {
			if (qBorder = v) this.component.style.border = "1px solid " + Lib.rgbf(borderColor, 1);
		}
		return v;
	}
	private function set_borderColor(v:Int) {
		if (borderColor != v) {
			borderColor = v;
			if (qBorder) this.component.style.border = "1px solid " + Lib.rgbf(borderColor, 1);
		}
		return v;
	}
	public function setTextFormat(v:TextFormat, ?f:Int, ?l:Int) {
		// Soon.
	}
	//
	private function get_text():String {
		return qEditable ? qTextArea.value : qText;
	}
	private function set_text(v:String):String {
		if (text != v) {
			var o, q:TextFormat = defaultTextFormat, z = qEditable;
			qText = v;
			if (z) {
				qTextArea.value = v;
			} else if (component.innerText == null) {
				component.innerHTML = StringTools.replace(StringTools.htmlEscape(v), "\n", "<br>");
			} else component.innerText = v;
			// update according styles:
			o = (z ? qTextArea : component).style;
			qFontStyle = o.font = q.get_fontStyle();
			untyped o.lineHeight = (qLineHeight = Std.int(q.size * 1.25)) + "px";
			o.color = flash.Lib.rgbf(q.color != null ? q.color : textColor, 1);
		}
		return v;
	}
	public function appendText(v:String):Void {
		text += v;
	}
	public function setSelection(v:Int, o:Int):Void {
		if (qEditable) qTextArea.setSelectionRange(v, o);
	}
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		// Not that good at the moment.
		var q:TextFormat = defaultTextFormat;
		ctx.save();
		ctx.fillStyle = component.style.color;
		ctx.font = qFontStyle;
		ctx.textBaseline = "top";
		ctx.textAlign = q.align != null ? q.align : "left";
		ctx.fillText(text, 0, 0);
		ctx.restore();
	}
	// Size
	override private function get_width():Float {
		return qWidth != null ? qWidth : get_textWidth();
	}
	override private function get_height():Float {
		return qHeight != null ? qHeight : get_textHeight();
	}
	override private function set_width(v:Float):Float {
		if (qWidth != v) {
			var o = (v != null ? v + "px" : "");
			component.style.width = o;
			if (qEditable) qTextArea.style.width = o;
			qWidth = v;
		}
		return v;
	}
	override private function set_height(v:Float):Float {
		if (qHeight != v) {
			var o = (v != null ? v + "px" : "");
			component.style.height = o;
			if (qEditable) qTextArea.style.height = o;
			qHeight = v;
		}
		return v;
	}
	// Text size
	private function _measure_pre():DivElement {
		// Copies style and text onto helper element
		var o = Lib.jsHelper(),
			s = o.style, q = component.style, i:Int;
		i = q.length; while (--i >= 0) untyped s[q[i]] = q[q[i]];
		o.innerHTML = component.innerHTML;
		return o;
	}
	private function _measure_post(o:DivElement):Void {
		// Clears previously set syle and text on given element.
		var i:Int, s = o.style;
		i = s.length; while (--i >= 0) untyped s[s[i]] = "";
		o.innerHTML = "";
	}
	private function get_textWidth():Float {
		if (stage == null) {
			var o = _measure_pre(),
				r = o.clientWidth;
			_measure_post(o);
			return r;
		}
		return component.clientWidth;
	}
	private function get_textHeight():Float {
		if (stage == null) {
			var o = _measure_pre(),
				r = o.clientHeight;
			_measure_post(o);
			return r;
		}
		return component.clientHeight;
	}
	private function get_numLines():Int {
		var r:Int = 0, p:Int = 0, d:String = text, l:Int = d.length;
		while (p < l) { r++; if ((p = d.indexOf("\n", p) + 1) == 0) p = l;}
		return r;
	}
	// Meta
	private function set_autoSize(v:String):String {
		if (autoSize != v) {
			if ((autoSize = v) != TextFieldAutoSize.NONE) width = height = null;
		}
		return v;
	}
	private function set_type(v:String):String {
		// Currently will cause event listener loss.
		// Is someone crazy enough to switch type mid-run though?
		var z:Bool = (v == "INPUT"), o:TextField = this, c:Element, e:TextAreaElement, q:Dynamic,
			t:Dynamic, text:String, f:Float;
		if (z != o.qEditable) {
			c = o.component;
			text = o.text; o.text = text != "" ? "" : " ";
			if (o.qEditable = z) {
				// create input node:
				c.appendChild(e = cast Lib.jsNode(multiline ? "textarea" : "input"));
				e.value = text + " ";
				e.maxLength = (t = maxChars) > 0 ? t : 2147483647;
				t = e.style;
				t.border = "0";
				t.background = "transparent";
				if ((f = o.qWidth) != null) t.width = f + "px";
				if ((f = o.qHeight) != null) t.height = f + "px";
				o.qTextArea = e;
			} else {
				// destroy input node:
				c.removeChild(o.qTextArea);
				o.qTextArea = null;
			}
			o.text = text;
		}
		return v;
	}
	private function set_multiline(v:Bool):Bool {
		if (multiline != v) {
			multiline = v;
			if (qEditable) {
				type = "DYNAMIC";
				type = "INPUT";
			}
		}
		return v;
	}
	private function set_maxChars(v:Int):Int {
		if (maxChars != v) {
			maxChars = v;
			if (qEditable) qTextArea.maxLength = v > 0 ? v : 2147483647;
		}
		return v;
	}
	private function set_selectable(v:Bool):Bool {
		if (selectable != v) {
			var s = component.style,
				q = (selectable = v) ? null : "none";
			Lib.setCSSProperty(s, "-webkit-touch-callout", q); // mobile webkit
			Lib.setCSSProperty(s, "cursor", v ? "" : "default");
			Lib.setCSSProperties(s, "user-select", q, 0x2F);
			// older IEs. They don't support HTML5 though, so why would this even be here...
			// component.setAttribute("unselectable", v ? null : "on"); // older IEs
		}
		return v;
	}
	override public function giveFocus():Void {
		(qEditable ? qTextArea : component).focus();
	}
	// selection:
	private function get_selectionBeginIndex():Int return qEditable ? qTextArea.selectionStart : 0;
	private function get_selectionEndIndex():Int return qEditable ? qTextArea.selectionEnd : 0;
	private function set_selectionBeginIndex(v:Int):Int {
		if (qEditable && selectionBeginIndex != v) {
			qTextArea.selectionStart = v;
		}
		return v;
	}
	private function set_selectionEndIndex(v:Int):Int {
		if (qEditable && selectionEndIndex != v) {
			qTextArea.selectionEnd = v;
		}
		return v;
	}
	private function get_selectedText():String {
		var a:Int = qTextArea.selectionStart,
			b:Int = qTextArea.selectionEnd,
			c:Int;
		if (b < a) { c = a; a = b; b = c; }
		return qEditable ? qTextArea.value.substring(a, b) : null;
	}
	// event target overrides:
	override public function hitTestLocal(x:Float, y:Float, p:Bool, ?v:Bool):Bool {
		return hitTestVisible(v) && x >= 0 && y >= 0 && x < width && y < height;
	}
	override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, weak:Bool = false):Void {
		var o = component;
		if (qEditable) component = qTextArea;
		super.addEventListener(type, listener, useCapture, priority, weak);
		if (qEditable) component = o;
	}
	override public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, weak:Bool = false):Void {
		var o = component;
		if (qEditable) component = qTextArea;
		super.removeEventListener(type, listener, useCapture, priority, weak);
		if (qEditable) component = o;
	}
}
#end