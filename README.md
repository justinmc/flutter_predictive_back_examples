# Predictive back examples

Various examples of Android's predictive back feature.

Currently only works when popping out of the Flutter app, not between routes
inside the Flutter app.

<img width="200" src="https://user-images.githubusercontent.com/389558/217918109-945febaa-9086-41cc-a476-1a189c7831d8.gif" />

## Getting predictive back to work in Flutter

  1. Run Android 33 or above.
  1. Enable the feature flag for predictive back on the device under "Developer
     options".
  1. Create a Flutter project, or clone this one.
  1. Set `android:enableOnBackInvokedCallback="true"` in
     android/app/src/main/AndroidManifest.xml (already done in this project).
  1. Make sure your version of Flutter contains
     [PR 120385](https://github.com/flutter/flutter/pull/120385). If it's not
     yet merged, you'll need to check out that branch specifically. After it is
     merged, compare the version it's in to your Flutter version, or use the
     latest master.
  1. Run the app. Perform a back gesture (swipe from the left side of the
     screen).

You should see the predictive back animation and be able to commit or cancel it.

## Resources

  - Migration guide: https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture
  - Code lab (Jetpack Compose): https://codelabs.developers.google.com/handling-gesture-back-navigation
