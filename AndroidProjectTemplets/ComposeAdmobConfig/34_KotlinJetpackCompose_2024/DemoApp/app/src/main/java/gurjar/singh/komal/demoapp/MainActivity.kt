package gurjar.singh.komal.demoapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import gurjar.singh.komal.demoapp.ui.theme.DemoAppTheme

// Util imports
import java.util.concurrent.atomic.AtomicBoolean
import android.util.Log
import android.content.Context
import androidx.compose.ui.viewinterop.AndroidView


// UMP consent Imports
import gurjar.singh.komal.demoapp.ads.GoogleMobileAdsConsentManager


// Admob fixed banner specific imports
//import com.google.android.gms.ads.MobileAds
//import com.google.android.gms.ads.AdRequest
//import com.google.android.gms.ads.AdSize
//import com.google.android.gms.ads.AdView

// Admob adaptive banner specific imports
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import androidx.window.layout.WindowMetricsCalculator
import androidx.compose.foundation.layout.fillMaxWidth


// remove in production
import android.widget.Toast


class MainActivity : ComponentActivity() {
	// Core properties //
	private lateinit var context: Context
	companion object {
	private const val TAG = "MainActivity"
	}

    // UMP properties //
    private lateinit var googleMobileAdsConsentManager: GoogleMobileAdsConsentManager

 // Admob properties //
 private val isMobileAdsInitializeCalled = AtomicBoolean(false)
private var showAdmobAds = AtomicBoolean(false)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            DemoAppTheme {
                // A surface container using the 'background' color from the theme
                Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                    //Greeting("Android")
                   // AdmobFixedBannerAd("ca-app-pub-3940256099942544/9214589741", showAdmobAds)
                   AdmobAdaptiveBannerAd("ca-app-pub-3940256099942544/6300978111", showAdmobAds)
                }
            }
        }
        
      // init properties
      context = applicationContext
        
      // init methods
      initUmpConsent()

    }
    
    
    
    // UMP methods //
 private fun initUmpConsent() {
    googleMobileAdsConsentManager = GoogleMobileAdsConsentManager.getInstance(applicationContext)
    googleMobileAdsConsentManager.gatherConsent(this) { error ->
      if (error != null) {
        // Consent not obtained in current session.
        Log.d(TAG, "${error.errorCode}: ${error.message}")
        //print ("${error.errorCode}: ${error.message}")
      }
      else
     {
     	//print ("error in consent")
     }

      if (googleMobileAdsConsentManager.canRequestAds) {
      	// consent gathered
        //print ("consent gathered")
        initializeMobileAdsSdk()
      }

      if (googleMobileAdsConsentManager.isPrivacyOptionsRequired) {
        // Regenerate the options menu to include a privacy setting.
        //invalidateOptionsMenu()
        includePrivacySetting()
      }
    }

    // This attempts to load ads using consent obtained in the previous session.
    if (googleMobileAdsConsentManager.canRequestAds) {
      initializeMobileAdsSdk()
    }

  }

private fun includePrivacySetting() {
	// TODO: show privacy options button
    return
}


// Admob methods //
private fun initializeMobileAdsSdk() {
    if (isMobileAdsInitializeCalled.getAndSet(true)) {
      return
    }
     // Initialize the Mobile Ads SDK.
    MobileAds.initialize(this) {}
    // TODO: Show ads after
    showAdmobAds.set(true)
}
  
  
// Testing, remove in production//
//private fun print(message: String) {
//    Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
//}

}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
            text = "Hello $name!",
            modifier = modifier
    )
}


// Admob Adaptive Banner Ad
@Composable
fun AdmobAdaptiveBannerAd(
bannerAdUnitId: String,
showAd: Boolean = false,
modifier: Modifier = Modifier
) {
	if (showAd) {
    AndroidView(
        modifier = modifier.fillMaxWidth(),
        factory = { context ->
            val windowMetrics: androidx.window.layout.WindowMetrics = WindowMetricsCalculator.getOrCreate().computeCurrentWindowMetrics(context)
            val bounds = windowMetrics.bounds

            var adWidthPixels: Float = context.resources.displayMetrics.widthPixels.toFloat()

            if (adWidthPixels == 0f) {
                adWidthPixels = bounds.width().toFloat()
            }

            val density: Float = context.resources.displayMetrics.density
            val adWidth = (adWidthPixels / density).toInt()

            AdView(context).apply {
                setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(context, adWidth))
                adUnitId = bannerAdUnitId
                loadAd(AdRequest.Builder().build())
            }
        }
    )}
}

// Admob Fixed Banner Ad
//@Composable
//fun AdmobFixedBannerAd(bannerAdUnitId: String, showAd: Boolean = false, modifier: Modifier = Modifier) {
//   if (showAd) {
// AndroidView(
//        modifier = modifier,
//        factory = { context ->
//            AdView(context).apply {
//                setAdSize(AdSize.BANNER)
//                adUnitId = bannerAdUnitId
//                loadAd(AdRequest.Builder().build())
//            }
//        }
//    )}
//}


// For preview in android studio
//@Preview(showBackground = true)
//@Composable
//fun GreetingPreview() {
//    DemoAppTheme {
//        Greeting("Android")
//    }
//}


