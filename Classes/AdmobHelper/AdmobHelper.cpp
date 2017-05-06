// #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
// #include "AdmobHelper.h"
// #include "platform/android/jni/JniHelper.h"
// #include <jni.h>
// #include <android/log.h>

// const char* NativeActivityClassName = "org/cocos2dx/lib/Cocos2dxActivity";

// void AdmobHelper::showAds(){
// 	cocos2d::JniMethodInfo t;
// if (cocos2d::JniHelper::getStaticMethodInfo(t
//                                                 , NativeActivityClassName
//                                                 , "showAdPopup"
//                                                 , "()V"))
// {
//   t.env->CallStaticVoidMethod(t.classID, t.methodID);
//   t.env->DeleteLocalRef(t.classID);
// }
// }
// #endif

#include "AdmobHelper.h"
#include "cocos2d.h"


bool AdmobHelper::isAdShowing = true;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include "platform/android/jni/JniHelper.h"
#include <jni.h>
//#include <android/log.h>


const char* AppActivityClassName = "org/cocos2dx/cpp/AppActivity";

void AdmobHelper::hideAd()
{
	cocos2d::JniMethodInfo t;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, AppActivityClassName, "hideAd", "()V"))
	{

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
		isAdShowing = false;
	}
}

void AdmobHelper::onPay()
{
	cocos2d::CCLog("onClick() called");
	cocos2d::JniMethodInfo t;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, AppActivityClassName, "onPay", "()V"))
	{

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}



void AdmobHelper::showAd()
{

	cocos2d::JniMethodInfo t;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, AppActivityClassName, "showAd", "()V"))
	{

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
		isAdShowing = true;
	}

}

#else


void AdmobHelper::hideAd()
{
	CCLOG("hideAd() called");
	isAdShowing = false;
	return; //nothing
}


void AdmobHelper::showAd()
{
	CCLOG("showAd() called");
	isAdShowing = true;
	return; //nothing;

}

void AdmobHelper::onPay()
{
	CCLOG("toastAndroid() called");
	return; //nothing
}


#endif
