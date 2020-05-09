package com.dartz.amiibo_network;

import android.app.Notification;
import android.app.NotificationChannel;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.FileProvider;

import android.app.PendingIntent;
import android.content.Intent;
import android.net.Uri;
import java.io.File;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.content.Context;
import android.content.ContextWrapper;
import android.annotation.SuppressLint;
import android.os.Build;
import java.util.Map;
import android.util.Log;

public class NotificationUtils extends ContextWrapper {

    private NotificationManagerCompat notificationManager;
    public static final String ANDROID_CHANNEL_ID = "Export";
    public static final String ANDROID_CHANNEL_NAME = "General Notifications";
    private static final String GROUP_ID = "AmiiboNetwork";
    private static final Integer SUMMARY_ID = 0;

    public NotificationUtils(Context base) {
        super(base);
        createChannels();
    }

    public void createChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            @SuppressLint("WrongConstant") NotificationChannel notificationChannel =
                new NotificationChannel(ANDROID_CHANNEL_ID, ANDROID_CHANNEL_NAME, NotificationManagerCompat.IMPORTANCE_LOW);
            notificationChannel.setDescription("Screenshots and exporting collections");
            notificationChannel.setShowBadge(false);
            getManager().createNotificationChannel(notificationChannel);
        }
    }

    public void sendNotification(Map<String, Object> arguments){
        String path = (String) arguments.get("path");
        String title = (String) arguments.get("title");
        String actionTitle = (String) arguments.get("actionTitle");
        Integer id = (Integer) arguments.get("id");

        Notification notification = createNotification(title, path, actionTitle, id);
        getManager().notify(id, notification);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Notification summary = createSummary(title, path);
            getManager().notify(SUMMARY_ID, summary);
        }
    }

    private Notification createNotification(String title, String path, String actionTitle, Integer id){
        String text = path.substring(path.lastIndexOf("/")+1);
        String type = path.substring(path.lastIndexOf(".")+1);
        File file = new File(path);
        Uri uri = FileProvider.getUriForFile(this, BuildConfig.APPLICATION_ID, file);
        //Log.v("Uri: ", uri.toString());

        NotificationCompat.Builder notificationBuilder =
            new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID);
        notificationBuilder//.setAutoCancel(true)
            .setSmallIcon(R.drawable.ic_notification)
            .setTicker(title)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentTitle(title)
            .setGroup(GROUP_ID)
            .setContentText(text);

        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);

        if(type.equals("png")){
            intent.setDataAndType(uri, "image/png");
            PendingIntent pContentIntent = PendingIntent.getActivity(this, id,
                intent, PendingIntent.FLAG_UPDATE_CURRENT);

            sendIntent.setType("image/png");
            PendingIntent pShareIntent = PendingIntent.getActivity(this, id,
                Intent.createChooser(sendIntent, null), PendingIntent.FLAG_UPDATE_CURRENT);

            Bitmap bitmap = BitmapFactory.decodeFile(path);
            notificationBuilder
                .addAction(android.R.drawable.ic_menu_share, actionTitle, pShareIntent)
                .setContentIntent(pContentIntent)
                .setLargeIcon(bitmap)
                .setStyle(new NotificationCompat.BigPictureStyle()
                    .bigPicture(bitmap)
                    .bigLargeIcon(null)
                );
        }
        if(type.equals("json")){
            /*intent.setDataAndType(uri, "text/plain");
            PendingIntent pIntent = PendingIntent.getActivity(this, id,
                intent, PendingIntent.FLAG_UPDATE_CURRENT);*/
            //Log.v("message: ", "Notification");

            sendIntent.setType("text/plain");
            PendingIntent pShareIntent = PendingIntent.getActivity(this, id,
                Intent.createChooser(sendIntent, null), PendingIntent.FLAG_UPDATE_CURRENT);

            notificationBuilder//.setContentIntent(pIntent)
                .addAction(android.R.drawable.ic_menu_share, actionTitle, pShareIntent);
        }

        return notificationBuilder.build();
    }

    private Notification createSummary(String title, String path){
        String text = path.substring(path.lastIndexOf("/")+1);

        NotificationCompat.Builder summaryBuilder =
            new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID);
        summaryBuilder.setAutoCancel(true)
            .setSmallIcon(R.drawable.ic_notification)
            .setTicker(title)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentTitle(title)
            .setGroup(GROUP_ID)
            .setGroupSummary(true);
            //.setContentText(text);

        return summaryBuilder.build();
    }

    public void cancelNotification(Integer id){
        getManager().cancel(id);
    }

    private NotificationManagerCompat getManager() {
        if (notificationManager == null) {
            notificationManager = NotificationManagerCompat.from(this);
        }
        return notificationManager;
    }

}