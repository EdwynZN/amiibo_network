package com.dartz.amiibo_network;
import java.io.IOException;
import java.util.Map;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity{
  private static final String CHANNEL = "com.dartz.amiibo_network/notification";
  private static final String CHANNEL_INFO = "com.dartz.amiibo_network/info_package";
  private NotificationUtils mNotificationUtils;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_INFO)
      .setMethodCallHandler(
         (call, result) -> {
            if(call.method.equals("version")){
              result.success(Build.VERSION.SDK_INT);
            }
            else result.notImplemented();
          }
      );

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        (call, result) -> {
          if(mNotificationUtils == null){
            mNotificationUtils = new NotificationUtils(this);
          }
          switch (call.method) {
            case "notification":
              Map<String, Object> arguments = call.arguments();
              mNotificationUtils.sendNotification(arguments);
              result.success(true);
              break;
            case "cancel":
              Integer id = call.arguments();
              mNotificationUtils.cancelNotification(id);
              result.success(true);
              break;
            case "cancelAll":
              result.success(false);
              break;
            case "saveImage":
              try{
                mNotificationUtils.showImageNotification(call.arguments());
                result.success(true);
              } catch(IOException e){
                result.error("IOException: ", e.getMessage(), null);
              }
              /*
              Map<String, Object> imgArguments = call.arguments();
              String name = (String)imgArguments.get("name");
              byte[] imageData = (byte[])imgArguments.get("buffer");
              try{
                Bitmap bitmap;
                if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) bitmap = MediaStoreFlutter.updateMediaStore(this, imageData, name);
                else bitmap = MediaStoreFlutter.updateLegacyMediaStore(this, imageData, name);
                result.success(true);
              } catch(IOException e){
                result.error("IOException: ", e.getMessage(), null);
              }
              */
              break;
            default:
              result.notImplemented();
              break;
            }
        }
      );
  }
}