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
import org.osmf.events.DynamicStreamEvent;
import org.osmf.events.MediaPlayerStateChangeEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.URLResource;
import org.osmf.traits.PlayState;

[Event(name="durationChange", type="org.osmf.events.TimeEvent")]
[Event(name="currentTimeChange", type="org.osmf.events.TimeEvent")]
[Event(name="videoComplete", type="org.osmf.events.TimeEvent")]
[Event(name="switchingChange", type="org.osmf.events.DynamicStreamEvent")]
public class VideoDisplay extends UIComponent {

    private var mediaPlayer:MediaPlayer;
    private var container:MediaContainer;
    private var localSource:String;
    private var element:MediaElement;
    private var mediaFactory:DefaultMediaFactory;

    public function VideoDisplay() {
        super();
        percentWidth = percentHeight = 100;
        minWidth = minHeight = 5;
    }

    override protected function createChildren():void {
        super.createChildren();

        mediaFactory = new DefaultMediaFactory();

        mediaPlayer = new MediaPlayer();
        mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
        mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, videoDurationChange);
        mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, videoTimeChange);
        mediaPlayer.addEventListener(TimeEvent.COMPLETE, onVideoComplete);
        mediaPlayer.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);

        container = new MediaContainer();

        addChild(container);

        if(localSource) {
            playMedia();
        }
    }

    public function onSeek(event:MouseEvent):void {
        var seekTo:Number = mediaPlayer.duration * (event.target.mouseX / event.target.width);
        mediaPlayer.seek(seekTo);
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if(container) {
            container.width = unscaledWidth;
            container.height = unscaledHeight;
        }
    }

    override protected function measure():void {
        super.measure();

        measuredWidth = mediaPlayer.mediaWidth;
        measuredHeight = mediaPlayer.mediaHeight;
        measuredMinWidth = measuredMinHeight = 5;
    }

    public function playMedia():void {
        if(mediaPlayer) {
            if(element) {
                if(container.containsMediaElement(element)) {
                    container.removeMediaElement(element);
                }
            }
            element = mediaFactory.createMediaElement(new URLResource(localSource));
            mediaPlayer.media = element;
            container.addMediaElement(element);
        }
    }

    public function play():void {
        mediaPlayer.play();
    }

    public function pause():void {
        mediaPlayer.pause();
    }

    public function stop():void {
        mediaPlayer.stop();
        container.width = 0;
        container.height = 0;
    }

    public function screenState(stageDisplayState:String):void {
        stage.displayState = stageDisplayState;
        container.width = stage.stageWidth;
        container.height = stage.stageHeight;
    }

    protected function onMediaSizeChange(e:DisplayObjectEvent):void {
        e.stopPropagation();
        invalidateSize();
        invalidateDisplayList();
    }


    public function set source(value:String):void {
        localSource = value;
    }

    public function set volume(volume:Number):void {
        mediaPlayer.volume = volume
    }

    public function set autoDynamicStreamSwitch(b : Boolean):void {
        mediaPlayer.autoDynamicStreamSwitch = b;
    }

    public function get autoDynamicStreamSwitch():Boolean {
        return mediaPlayer.autoDynamicStreamSwitch;
    }

    public function get numDynamicStreams():int {
        return mediaPlayer.numDynamicStreams;
    }

    public function get currentDynamicStreamIndex():int {
        return mediaPlayer.currentDynamicStreamIndex;
    }

    public function get maxAllowedDynamicStreamIndex():int {
        return mediaPlayer.maxAllowedDynamicStreamIndex;
    }

    public function getBitrateForDynamicStreamIndex(dynamicStreamIntex:int):Number {
        var bitrate:Number = mediaPlayer.getBitrateForDynamicStreamIndex(dynamicStreamIntex);
        return bitrate;
    }

    public function switchDynamicStreamIndex(streamIndex:int):void {
        mediaPlayer.switchDynamicStreamIndex(streamIndex);
    }

    private function onSwitchingChange(event:DynamicStreamEvent):void {
        dispatchEvent(event);
    }

    private function videoDurationChange(event:TimeEvent):void {
        dispatchEvent(event);
    }

    private function videoTimeChange(event:TimeEvent):void {
        dispatchEvent(event);
    }

    private function onVideoComplete(event:TimeEvent):void {
        //TODO: Узнать, почему не отправляется событие в поток событий
        dispatchEvent(event);
    }
}
}
