package com.iapppay.demo.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Toast;

import com.iapppay.interfaces.callback.IPayResultCallback;
import com.iapppay.sdk.main.IAppPay;
import com.iapppay.sdk.main.IAppPayOrderUtils;
import com.iapppay.pay.v4.R;

/**
 * 完整接入流程 实例
 * 1：IAppPay.init（）//建议在APP的第一个界面调用
 * 2：IAppPay.startPay（）//发起支付
 */
public class MainDemoActivity extends Activity implements View.OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.iapppay_demo_activity_main_demo);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);//横屏：根据传感器横向切换

        findViewById(R.id.btn_submit_pay).setOnClickListener(this);
        findViewById(R.id.tv_more_pay_type).setOnClickListener(this);

        /**
         * SDK初始化 ，请放在游戏启动界面
         */
        IAppPay.init(MainDemoActivity.this, IAppPay.PORTRAIT, PayConfig.appid);//接入时！不要使用Demo中的appid
    }

    @Override
    public void onClick(View view) {

        if(view.getId() == R.id.btn_submit_pay){
            String cporderid = System.currentTimeMillis()   + "";
            String param = getTransdata("userid001", "cpprivateinfo123456" , 6 , 0.01f , cporderid);
            IAppPay.startPay(MainDemoActivity.this, param, iPayResultCallback);

        }else if(view.getId() == R.id.tv_more_pay_type){
            Intent intent = new Intent();
            intent.setClass(MainDemoActivity.this, PaySettingActivity.class);
            startActivity(intent);

        }
    }

    /**
     * 支付结果回调
     */
    IPayResultCallback iPayResultCallback = new IPayResultCallback() {

        @Override
        public void onPayResult(int resultCode, String signvalue, String resultInfo) {
            // TODO Auto-generated method stub
            switch (resultCode) {
                case IAppPay.PAY_SUCCESS:
                    //调用 IAppPayOrderUtils 的验签方法进行支付结果验证
                    boolean payState = IAppPayOrderUtils.checkPayResult(signvalue, PayConfig.publicKey);
                    if(payState){
                        Toast.makeText(MainDemoActivity.this, "支付成功", Toast.LENGTH_LONG).show();
                    }
                    break;
                default:
                    Toast.makeText(MainDemoActivity.this, resultInfo, Toast.LENGTH_LONG).show();
                    break;
            }
            Log.d("MainDemoActivity", "requestCode:" + resultCode + ",signvalue:" + signvalue + ",resultInfo:" + resultInfo);
        }
    };


    /** 获取收银台参数 */
    private String getTransdata( String appuserid, String cpprivateinfo, int waresid, float price, String cporderid) {
        //调用 IAppPayOrderUtils getTransdata() 获取支付参数
        IAppPayOrderUtils orderUtils = new IAppPayOrderUtils();
        orderUtils.setAppid(PayConfig.appid);
        orderUtils.setWaresid(waresid);//传入您商户后台创建的商品编号
        orderUtils.setCporderid(cporderid);
        orderUtils.setAppuserid(appuserid);
        orderUtils.setPrice(price);//单位 元
        orderUtils.setWaresname("自定义名称");//开放价格名称(用户可自定义，如果不传以后台配置为准)
        orderUtils.setCpprivateinfo(cpprivateinfo);
        return orderUtils.getTransdata(PayConfig.privateKey);
    }

}
