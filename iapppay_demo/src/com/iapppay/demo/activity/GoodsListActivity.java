package com.iapppay.demo.activity;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;

import com.iapppay.interfaces.callback.IPayResultCallback;
import com.iapppay.sdk.main.IAppPay;
import com.iapppay.sdk.main.IAppPayOrderUtils;
import com.iapppay.pay.v4.R;

/**
 * 商品列表
 * 提供不用计费策略的演示
 */
public class GoodsListActivity extends Activity implements View.OnClickListener{
    private static final int waresid_with_times = 1;		//按次
    private static final int waresid_first_times = 5;		//首次洗车，后续不收费（6元） (买断)
    private static final int waresid_wrap_times = 3;		//1元5次  (包次数)
    private static final int waresid_wrap_timeLength = 4;	//5元1天   (包时长)
    private static final int waresid_open_price = 6;		//开放价格

    private static final String TAG = GoodsListActivity.class.getSimpleName();

    /**
     * 以下参数在文档中有详细介绍
     */
    private String appuserid = "";
    private String cpprivateinfo= "cpprivateinfo123456";
    private String cporderid= "";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.iapppay_demo_activity_goods_list);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

        int screenType = getIntent().getIntExtra("screentype", ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        if (screenType == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);//横屏：固定方向，屏幕向左倾斜方向
        }else if (screenType == ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);//横屏：根据传感器横向切换
        }else if (screenType == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }

        findViewById(R.id.ll_btn1).setOnClickListener(this);
        findViewById(R.id.ll_btn2).setOnClickListener(this);
        findViewById(R.id.ll_btn3).setOnClickListener(this);
        findViewById(R.id.ll_btn4).setOnClickListener(this);
        findViewById(R.id.btn_kaifangjiage).setOnClickListener(this);
        /**
         * SDK初始化 ，请放在游戏启动界面
         */
        IAppPay.init(GoodsListActivity.this, screenType, PayConfig.appid);//接入时！不要使用Demo中的appid
    }
    @Override
    public void onClick(View v) {
        /**
         * appuserid代表用户的唯一标识，不能为空，且必须真实有效, 有帐号的情况下，请传帐号的标识。如果没有帐号，可以使用设备标识。
         * 这里演示没有帐号的情况，以DeviceId作为用户的标识。
         */
        TelephonyManager telephonyManager = (TelephonyManager) this.getSystemService(Context.TELEPHONY_SERVICE);
        appuserid = getIntent().getStringExtra("appuserid");
        appuserid = TextUtils.isEmpty(appuserid) ? telephonyManager.getDeviceId() : appuserid;
        cporderid = System.currentTimeMillis()   + "";

        switch (v.getId()) {
            case R.id.ll_btn1:
                startPay(GoodsListActivity.this, getTransdata(appuserid, cpprivateinfo , waresid_with_times , 1 , cporderid));
                break;
            case R.id.ll_btn2:
                startPay(GoodsListActivity.this, getTransdata(appuserid, cpprivateinfo , waresid_first_times , 6 , cporderid));
                break;
            case R.id.ll_btn3:
                startPay(GoodsListActivity.this, getTransdata(appuserid, cpprivateinfo , waresid_wrap_times , 1, cporderid));
                break;
            case R.id.ll_btn4:
                startPay(GoodsListActivity.this, getTransdata(appuserid, cpprivateinfo , waresid_wrap_timeLength , 5, cporderid));
                break;
            case R.id.btn_kaifangjiage:
                final EditText etPrice = (EditText) findViewById(R.id.et_input_price);

                String price = etPrice.getText().toString().trim();

                if (TextUtils.isEmpty(price)) {
                    Toast.makeText(GoodsListActivity.this, "请输入收费金额",Toast.LENGTH_SHORT).show();
                    etPrice.requestFocus();
                } else if (".".equals(price)) {
                    Toast.makeText(GoodsListActivity.this, "请输入正确金额", Toast.LENGTH_LONG).show();
                    etPrice.requestFocus();
                } else if (Double.parseDouble(price) <= 0) {
                    Toast.makeText(GoodsListActivity.this, "收费金额应大于0",Toast.LENGTH_SHORT).show();
                    etPrice.requestFocus();
                } else {
                    float iprice = 0;
                    try {
                        iprice = Float.parseFloat(price) / 100.00f;//UI上面输入的单位是分，传入后台需要转换成单位 元
                    } catch (Exception e) {
                        Toast.makeText(GoodsListActivity.this, "金额不合法",Toast.LENGTH_LONG).show();
                        return;
                    }

                    //关闭软键盘
                    ((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(getCurrentFocus().getWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
                    //启动收银台
                    startPay(GoodsListActivity.this, getTransdata(appuserid, cpprivateinfo , waresid_open_price , iprice , cporderid));
                }
                break;
            default:
                break;
        }
    }


    /** 获取收银台参数 */
    private String getTransdata( String appuserid, String cpprivateinfo, int waresid, float price, String cporderid) {
        //调用 IAppPayOrderUtils getTransdata() 获取支付参数
        IAppPayOrderUtils orderUtils = new IAppPayOrderUtils();
        orderUtils.setAppid(PayConfig.appid);
        orderUtils.setWaresid(waresid);
        orderUtils.setCporderid(cporderid);
        orderUtils.setAppuserid(appuserid);
        orderUtils.setPrice(price);//单位 元
        orderUtils.setWaresname("自定义名称");//开放价格名称(用户可自定义，如果不传以后台配置为准)
        orderUtils.setCpprivateinfo(cpprivateinfo);
        return orderUtils.getTransdata(PayConfig.privateKey);
    }


    /**发起支付*/
    public void startPay(Activity activity, String param) {
         IAppPay.startPay(activity, param, iPayResultCallback);
    }
    /**
     * 支付结果回调
     */
    IPayResultCallback iPayResultCallback = new IPayResultCallback() {

        @Override
        public void onPayResult(int resultCode, String signvalue, String resultInfo) {
            switch (resultCode) {
                case IAppPay.PAY_SUCCESS:
                    //调用 IAppPayOrderUtils 的验签方法进行支付结果验证
                    boolean payState = IAppPayOrderUtils.checkPayResult(signvalue, PayConfig.publicKey);
                    if(payState){
                        Toast.makeText(GoodsListActivity.this, "支付成功", Toast.LENGTH_LONG).show();
                    }
                    break;
                default:
                    Toast.makeText(GoodsListActivity.this, resultInfo, Toast.LENGTH_LONG).show();
                    break;
            }
            Log.d(TAG, "requestCode:"+resultCode + ",signvalue:" + signvalue + ",resultInfo:"+resultInfo);
        }
    };

}
