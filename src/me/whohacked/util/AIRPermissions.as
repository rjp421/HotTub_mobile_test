/* blame ChatGPT, just testing */
package me.whohacked.util {

    import flash.media.Camera;
    import flash.media.Microphone;
    import flash.net.NetworkInfo;
    import flash.net.NetworkInterface;
    import flash.events.PermissionEvent;
    import flash.permissions.PermissionStatus;

    public class AIRPermissions {

        public static function checkCameraPermission():String {
            var camera:Camera = Camera.getCamera();
            if (!camera) {
                return PermissionStatus.DENIED;
            } else if (camera.muted) {
                return PermissionStatus.UNKNOWN;
            } else {
                return PermissionStatus.GRANTED;
            }
        }

        public static function checkMicrophonePermission():String {
            var microphone:Microphone = Microphone.getMicrophone();
            if (!microphone) {
                return PermissionStatus.DENIED;
            } else if (microphone.muted) {
                return PermissionStatus.UNKNOWN;
            } else {
                return PermissionStatus.GRANTED;
            }
        }

        public static function checkNetworkPermission():String {
            var networkInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
            for each (var networkInterface:NetworkInterface in networkInterfaces) {
                if (networkInterface.active && networkInterface.displayName != "Loopback Pseudo-Interface 1") {
                    return PermissionStatus.GRANTED;
                }
            }
            return PermissionStatus.DENIED;
        }

        public static function requestCameraPermission():void {
            Camera.getCamera().requestPermission();
        }

        public static function requestMicrophonePermission():void {
            Microphone.getMicrophone().requestPermission();
        }

        public static function requestNetworkPermission():void {
            // no need to request network permission on target Android 11
        }
    }
}