package com.iapppay.demo.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.Toast;

import com.iapppay.sdk.main.IAppPay;
import com.iapppay.pay.v4.R;

/**
 * Demo演示使用
 * 1：输入AppUserID
 * 2：设置横竖屏
 */
public class PaySettingActivity extends Activity implements View.OnClickListener{
    EditText appText;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.iapppay_demo_activity_pay_setting);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);


        appText = (EditText) findViewById(R.id.appuseridEdit);
        findViewById(R.id.btn_portrait).setOnClickListener(this);
        findViewById(R.id.btn_landscape).setOnClickListener(this);
        findViewById(R.id.btn_sensor).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.btn_portrait){
            setting(IAppPay.PORTRAIT);
        }else if(view.getId() == R.id.btn_landscape){
            setting(IAppPay.LANDSCAPE);
        }else if(view.getId() == R.id.btn_sensor){
            setting(IAppPay.SENSOR_LANDSCAPE);
        }
    }
    private void setting(int sdkType){
        String appUserID = appText.getEditableText().toString();
        if (TextUtils.isEmpty(appUserID)) {
            Toast.makeText(PaySettingActivity.this, "请输入AppUserID", Toast.LENGTH_SHORT).show();
            appText.requestFocus();
            return;
        }

        Intent intent = new Intent(PaySettingActivity.this, GoodsListActivity.class);
        intent.putExtra("appuserid", appUserID);//用户在商户应用的唯一标识，建议为用户帐号。对于游戏，需要区分到不同区服，#号分隔；比如游戏帐号abc在01区，则传入“abc#01”
        intent.putExtra("screentype", sdkType);
        startActivity(intent);
    }
}
