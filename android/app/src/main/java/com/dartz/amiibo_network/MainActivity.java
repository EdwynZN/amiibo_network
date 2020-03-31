package com.dartz.amiibo_network;

import java.util.Map;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity{
  private static final String CHANNEL = "com.dartz.amiibo_network/notification";
  private NotificationUtils mNotificationUtils;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

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
            default:
              result.notImplemented();
              break;
            }
        }
      );
  }
}