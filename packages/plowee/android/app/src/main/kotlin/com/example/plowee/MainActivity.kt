package com.example.plowee

import io.flutter.embedding.android.FlutterActivity
import com.google.android.libraries.places.api.Places

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Places.initialize(applicationContext, "AIzaSyCcEEXbsnVt9ESSxQmPDImXuEtjl9VkP3M")
    }
}