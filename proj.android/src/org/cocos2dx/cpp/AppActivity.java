/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.cpp;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Timer;
import java.util.TimerTask;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.annotation.TargetApi;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.Point;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.WindowManager;
import android.widget.RelativeLayout;
import android.widget.Toast;


import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.*;

public class AppActivity extends Cocos2dxActivity{
	RelativeLayout mAdContainer;	
    private static final int REQUEST_ACHIEVEMENTS = 10000;  
    private static final int REQUEST_LEADERBOARDS = 10001;  
    private static final int REQUEST_LEADERBOARD = 10002;  
//    private AdView mAdView;

	private static AppActivity _appActiviy;
	private static int result;
	private AdView adView;
	private static final String AD_UNIT_ID = "ca-app-pub-2641376718074288/4798565659";
	public static native void SendInfo(String info);
	public static native void noAd();


	// Helper get display screen to avoid deprecated function use
	private Point getDisplaySize(Display d)
	    {
	        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
	        {
	            return getDisplaySizeGE11(d);
	        }
	        return getDisplaySizeLT11(d);
	    }

	    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR2)
	    private Point getDisplaySizeGE11(Display d)
	    {
	        Point p = new Point(0, 0);
	        d.getSize(p);
	        return p;
	    }
	    private Point getDisplaySizeLT11(Display d)
	    {
	        try
	        {
	            Method getWidth = Display.class.getMethod("getWidth", new Class[] {});
	            Method getHeight = Display.class.getMethod("getHeight", new Class[] {});
	            return new Point(((Integer) getWidth.invoke(d, (Object[]) null)).intValue(), ((Integer) getHeight.invoke(d, (Object[]) null)).intValue());
	        }
	        catch (NoSuchMethodException e2) // None of these exceptions should ever occur.
	        {
	            return new Point(-1, -1);
	        }
	        catch (IllegalArgumentException e2)
	        {
	            return new Point(-2, -2);
	        }
	        catch (IllegalAccessException e2)
	        {
	            return new Point(-3, -3);
	        }
	        catch (InvocationTargetException e2)
	        {
	            return new Point(-4, -4);
	        }
	    }

	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);//横屏：根据传感器横向切换

        int width = getDisplaySize(getWindowManager().getDefaultDisplay()).x;
        RelativeLayout layout = new RelativeLayout(this);  
        LayoutParams lp = new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT);
        addContentView(layout,lp);
        RelativeLayout.LayoutParams adParams = new RelativeLayout.LayoutParams(
        width,LayoutParams.WRAP_CONTENT);
        adParams.setMargins(5, 5, 5, 5);
        adView = new AdView(this);
        adView.setAdSize(AdSize.BANNER);
        adView.setAdUnitId(AD_UNIT_ID);
        adParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        AdRequest adRequest = new AdRequest.Builder().addTestDevice(AdRequest.DEVICE_ID_EMULATOR).build();

        adView.loadAd(adRequest);
        adView.setBackgroundColor(Color.BLACK);
        adView.setBackgroundColor(0);
        layout.addView(adView,adParams);
         _appActiviy = this;
    }
    //支付
    private static AppActivity instance= new AppActivity();
    
    public static Object getObj(){

    	return instance;
    }
    
    public static void hideAd(){
    	_appActiviy.runOnUiThread(new Runnable(){
			  @Override
			  public void run(){
					if (_appActiviy.adView.isEnabled())
						_appActiviy.adView.setEnabled(false);
					if (_appActiviy.adView.getVisibility() != 4 )
						_appActiviy.adView.setVisibility(View.INVISIBLE);
			  }
    	});
   }


    public static void showAd(){
    	
    	_appActiviy.runOnUiThread(new Runnable(){

			    @Override
			    public void run(){	
					if (!_appActiviy.adView.isEnabled())
						_appActiviy.adView.setEnabled(true);
					if (_appActiviy.adView.getVisibility() == 4 )
						_appActiviy.adView.setVisibility(View.VISIBLE);	
			    }
		});
   }

        
      
    private boolean MyStartActivity(Intent aIntent) {
        try
        {
            startActivity(aIntent);
            return true;
        }
        catch (ActivityNotFoundException e)
        {
            return false;
        }
    }
    
    
        @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (adView != null) {
        	adView.pause();
        	}

    }

    @Override
    protected void onResume() {
        super.onResume();
        if (adView != null) {
        	adView.resume();
        	}

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        adView.destroy();
    }

    @Override
    protected void onActivityResult(int reqCode, int resCode, Intent data) {
        super.onActivityResult(reqCode, resCode, data);
    }
    
    // In onBackPressed()
    @Override
    public void onBackPressed(){ // If an interstitial is on screen, close it. Otherwise continue as normal. 
    	Log.v("hey","quit");
//    	if (this.cb.onBackPressed()) return; 
    	super.onBackPressed();    
    }
    
    /** 
     * 菜单、返回键响应 
     */  
    @Override  
    public boolean onKeyDown(int keyCode, KeyEvent event) {  
        // TODO Auto-generated method stub  
        if(keyCode == KeyEvent.KEYCODE_BACK)  
           {    
               exitBy2Click();      //调用双击退出函数  
           }  
        return false;  //不会执行退出事件
    }  
    /** 
     * 双击退出函数 
     */  
    private static Boolean isExit = false;  
      
    private void exitBy2Click() {  
        Timer tExit = null;  
        if (isExit == false) {  
            isExit = true; // 准备退出  
            Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();  
            tExit = new Timer();  
            tExit.schedule(new TimerTask() {  
                @Override  
                public void run() {  
                    isExit = false; // 取消退出  
                }  
            }, 2000); // 如果2秒钟内没有按下返回键，则启动定时器取消掉刚才执行的任务  
      
        } else {  
            finish();  
            System.exit(0);  
        }  
    }           
}
