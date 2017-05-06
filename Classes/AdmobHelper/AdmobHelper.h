// #ifndef  __Admob_Helper_H_
// #define  __Admob_Helper_H_
// class AdmobHelper
// {
// public:
//     static void showAds();
// //if necessary, you can add other methods to control AdView(e.g. dismiss the AdView).
// };
// #endif  //__ADMOB_HELPER_H_

#ifndef  __ADMOB_HELPER_H_
#define  __ADMOB_HELPER_H_

class AdmobHelper
{
public:
	static void hideAd();
	static void showAd();
	static bool isAdShowing;
	static void onPay();

};


#endif // __ADMOB_HELPER_H_
