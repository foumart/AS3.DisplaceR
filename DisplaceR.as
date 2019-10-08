/*
  Copyright (c) 2013 Noncho Savov | Foumart Games | http://www.foumartgames.com
  All rights reserved.

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the 
    documentation and/or other materials provided with the distribution.
  
  * Neither the name of Adobe Systems Incorporated nor the names of its 
    contributors may be used to endorse or promote products derived from 
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.foumart.effects {
  
	/**
	* 	DisplaceR is a Displacement Map Tweener built with
	*	DisplacementMapFilter and the native flash Tweener.
	*	It provides static mothods such is the 'to()' method
	*	for displacement manipulation of a source display object
	*	according the color data of provided map image.
	*	Displacement is as follows:
	*	#00(max negative) - #7F(no displacement) - #FF(max positive);
	*	Red color channel displaces in X axis while Green displaces in Y
	*	
	* 	@langversion ActionScript 3.0
	*	@playerversion Flash 9.0
	*	@tiptext
	*/		
	
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.BitmapFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	import fl.transitions.TweenEvent;
	
	public class DisplaceR {
		
		public static var onComplete:Function;
		public static var onCompleteParams:Array;
		
		private static var tweener:TweenerCheck;
		private static var instance:DisplaceR;
		
		public static var isTweener:Boolean;
		public static var tween:Tween;
		
		public var displacedObject:DisplayObject;
		public var displaceMap:BitmapData;
		public var mapBitmap:BitmapData;
		
		private var _displace:Number = 0;
		
		private var _timeout:uint;
		
		
		/**
		*	Applies displacement transformtion and tweens the ammount of displacement.
		* 
		* 	@param object_to_displace The display object that will be displaced.
		*
		*	@param displace_map The object that holds the displacement color data
		* 
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/
		public static function to(	object_to_displace:DisplayObject,
						displace_map:DisplayObject,
						ease:Function = null,
						ammount:Number = 0,
						duration:Number = 0,
						useSeconds:Boolean = true):void {
			if( instance == null ) {
				tweener = new TweenerCheck(object_to_displace, ease, ammount, duration, useSeconds)
				instance = new DisplaceR(tweener, displace_map);
			} else {
				tweener.ease = ease;
				tweener.ammount = ammount;
				tweener.duration = duration;
				tweener.useSeconds = useSeconds;
				instance.init(object_to_displace, displace_map);
			}
		}
		
		public static function dispose():void{
			onComplete = null;
			onCompleteParams = null;
			tweener = null;
			isTweener = false;
			tween.stop();
			tween = null;
			instance = null;
			//displacedObject = null;
			//displaceMap = null;
			//mapBitmap = null;
			//_displace = 0;
			//clearTimeout(_timeout);
		}
		
		public function DisplaceR(object_to_displace:* = null, displace_map:DisplayObject = null) {
			if(displace_map is MovieClip || displace_map is Sprite){
				displace_map.visible = false;
			}
			if(object_to_displace is TweenerCheck) {
				//trace("DisplaceR initialized as Tweeer");
				isTweener = true;
				_timeout = setTimeout(function():void{init(object_to_displace, displace_map)}, 1);
				if(displace_map is BitmapData) displace_map.visible = false;
			} else if(isTweener){
				init(object_to_displace, displace_map);
			} else {
				//trace("DisplaceR initialized as Object with 'displace' property");
				constructor(object_to_displace, displace_map);
			}
		}
		
		public function constructor(object_to_displace:* = null, displace_map:DisplayObject = null):void{
			if(displace_map is BitmapData){
				displaceMap = displace_map as BitmapData;
			} else {
				displaceMap = new BitmapData(displace_map.width, displace_map.height, false);
				displaceMap.draw(displace_map);
			}
			displacedObject = object_to_displace;
		}
		
		public function init(object_to_displace:* = null, displace_map:DisplayObject = null):void{
			if(displace_map is BitmapData){
				displaceMap = displace_map as BitmapData;
			} else {
				displaceMap = new BitmapData(displace_map.width, displace_map.height, false);
				displaceMap.draw(displace_map);
			}
			if(object_to_displace is TweenerCheck) {
				displacedObject = object_to_displace.source;
				tween = new Tween(instance, "displace", object_to_displace.ease, displace, object_to_displace.ammount, object_to_displace.duration, object_to_displace.useSeconds);
			} else {
				displacedObject = object_to_displace;
				tween = new Tween(instance, "displace", tweener.ease, displace, tweener.ammount, tweener.duration, tweener.useSeconds);
			}
			tween.addEventListener(TweenEvent.MOTION_FINISH, motionFinish);
		}
		
		private function motionFinish(evt:TweenEvent):void{
			tween.removeEventListener(TweenEvent.MOTION_FINISH, motionFinish);
			if(onCompleteParams){
				if(onComplete != null) onComplete(onCompleteParams);
			} else if(onComplete != null) onComplete();
		}
		

		private function getBitmapFilter(_scale:Number = 0):BitmapFilter {
			mapBitmap = displaceMap;
			var mapPoint:Point = new Point(0,0);
			var componentX:uint = BitmapDataChannel.RED;
			var componentY:uint = BitmapDataChannel.GREEN;
			var scaleX:Number = _scale;
			var scaleY:Number = _scale;
			var mode:String = DisplacementMapFilterMode.COLOR;
			var color:uint = 0;
			var alpha:Number = 0;
			return new DisplacementMapFilter(
				mapBitmap,
				mapPoint,
				componentX,
				componentY,
				scaleX,
				scaleY,
				mode,
				color,
				alpha
			);
		}
		
		public function set displace(value:Number):void {
			_displace = value;
			displacedObject.filters = [getBitmapFilter(_displace)];
		}
		
		public function get displace():Number {
			return _displace;
		}
	}
}


import flash.display.DisplayObject;

internal class TweenerCheck{
	
	public var source:DisplayObject;
	public var ease:Function;
	public var ammount:Number;
	public var duration:Number;
	public var useSeconds:Boolean;
	
	public function TweenerCheck(	_source:DisplayObject,
					_ease:Function = null,
					_ammount:Number = 0,
					_duration:Number = 0,
					_useSeconds:Boolean = true) {
		source = _source;
		ease = _ease;
		ammount = _ammount;
		duration = _duration;
		useSeconds = _useSeconds;
	}
}
