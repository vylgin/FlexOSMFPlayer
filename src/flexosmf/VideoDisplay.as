/**
 * Created by vylgin on 26.04.14.
 */
package flexosmf {
import flash.display.StageDisplayState;
import flash.events.MouseEvent;

import mx.core.UIComponent;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.VideoElement;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.URLResource;

[Event(name="durationChange", type="org.osmf.events.TimeEvent")]
[Event(name="currentTimeChange", type="org.osmf.events.TimeEvent")]
[Event(name="videoComplete", type="org.osmf.events.TimeEvent")]
public class VideoDisplay extends UIComponent {
    private var _mediaPlayer:MediaPlayer;
    private var _container:MediaContainer;
    private var _source:String;
    private var _element:MediaElement;
    private var _mediaFactory:DefaultMediaFactory;

    public function VideoDisplay() {
        super();
        percentWidth = percentHeight = 100;
        minWidth = minHeight = 5;
    }

    override protected function createChildren() :void {
        super.createChildren();

        _mediaFactory = new DefaultMediaFactory();

        _mediaPlayer = new MediaPlayer();
        _mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
        _mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, videoDurationChangeHandler);
        _mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, videoTimeChangeHandler);
        _mediaPlayer.addEventListener(TimeEvent.COMPLETE, videoCompleteHandler);

        _container = new MediaContainer();

        addChild(_container);

        if( _source ) {
            playMedia();
        }
    }

    public function onSeek(event:MouseEvent):void {
        var seekTo:Number = _mediaPlayer.duration * (event.target.mouseX / event.target.width);
        _mediaPlayer.seek(seekTo);
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if( _container ) {
            _container.width = unscaledWidth;
            _container.height = unscaledHeight;
        }
    }

    override protected function measure():void {
        super.measure();

        measuredWidth = _mediaPlayer.mediaWidth;
        measuredHeight = _mediaPlayer.mediaHeight;
        measuredMinWidth = measuredMinHeight = 5;
    }

    public function playMedia():void {
        if(_mediaPlayer) {
            if(_element) {
                if(_container.containsMediaElement(_element)) {
                    _container.removeMediaElement(_element);
                }
            }
            _element = _mediaFactory.createMediaElement(new URLResource(_source));
            _mediaPlayer.media = _element;
            _container.addMediaElement(_element);
        }
    }

    public function play():void {
        _mediaPlayer.play();
    }

    public function pause():void {
        _mediaPlayer.pause();
    }

    public function stop():void {
        _mediaPlayer.stop();
        _container.width = 0;
        _container.height = 0;
    }

    public function screenState(stageDisplayState:String):void {
        stage.displayState = stageDisplayState;
        _container.width = stage.stageWidth;
        _container.height = stage.stageHeight;
    }

    protected function onMediaSizeChange(e:DisplayObjectEvent):void {
        e.stopPropagation();
        invalidateSize();
        invalidateDisplayList();
    }
    public function set source(value:String) :void {
        _source = value;
    }

    public function set volume(volume:Number) {
        _mediaPlayer.volume = volume
    }

    private function videoDurationChangeHandler(event:TimeEvent):void {
        dispatchEvent(event);
    }

    private function videoTimeChangeHandler(event:TimeEvent):void {
        dispatchEvent(event);
    }

    private function videoCompleteHandler(event:TimeEvent):void {
        dispatchEvent(event); //TODO: Выяснить, почему не отправляется событие в поток событий
    }

    public static function timeFormat(time:int):String {
        var minutes:int = time / 60;
        var seconds:int = time % 60;
        var min:String = minutes < 10 ? "0" + minutes : "" + minutes;
        var sec:String = seconds < 10 ? "0" + seconds : "" + seconds;

        return min + ":" + sec;
    }
}
}
