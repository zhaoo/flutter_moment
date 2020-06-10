package com.example.flutter_moment

import io.flutter.embedding.android.FlutterActivity
import android.os.Build;
import android.os.Bundle;

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = 0
        }
    }
}
