package com.reactlibrary;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.JsonRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.payfort.fort.android.sdk.base.FortSdk;
import com.payfort.fort.android.sdk.base.callbacks.FortCallBackManager;
import com.payfort.fort.android.sdk.base.callbacks.FortCallback;
import com.payfort.sdk.android.dependancies.base.FortInterfaces;
import com.payfort.sdk.android.dependancies.models.FortRequest;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

public class PayfortActivity extends Activity {

    FortCallBackManager fortCallback;
    ProgressDialog pbLoading;
    String deviceId, isLive, accessCode, merchantIdentifier, requestPhrase,
            customerEmail, currency, amount, merchantReference, customerName, customerIp, paymentOption, orderDescription;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_payfort);

        parseData();

        pbLoading = new ProgressDialog(this);
        pbLoading.setMessage("Fetching data...");
        pbLoading.show();

        fortCallback = FortCallback.Factory.create();
        deviceId = FortSdk.getDeviceId(PayfortActivity.this);

        requestGetToken();
    }

    private void parseData() {
        Intent intent = getIntent();
        if (intent.hasExtra("is_live")) {
            isLive = intent.getStringExtra("is_live");
        }
        if (intent.hasExtra("access_code")) {
            accessCode = intent.getStringExtra("access_code");
        }
        if (intent.hasExtra("merchant_identify")) {
            merchantIdentifier = intent.getStringExtra("merchant_identify");
        }
        if (intent.hasExtra("request_phrase")) {
            requestPhrase = intent.getStringExtra("request_phrase");
        }
        if (intent.hasExtra("customer_email")) {
            customerEmail = intent.getStringExtra("customer_email");
        }
        if (intent.hasExtra("currency")) {
            currency = intent.getStringExtra("currency");
        }
        if (intent.hasExtra("amount")) {
            amount = intent.getStringExtra("amount");
        }
        if (intent.hasExtra("merchant_reference")) {
            merchantReference = intent.getStringExtra("merchant_reference");
        }
        if (intent.hasExtra("customer_name")) {
            customerName = intent.getStringExtra("customer_name");
        }
        if (intent.hasExtra("customer_ip")) {
            customerIp = intent.getStringExtra("customer_ip");
        }
        if (intent.hasExtra("payment_option")) {
            paymentOption = intent.getStringExtra("payment_option");
        }
        if (intent.hasExtra("order_description")) {
            orderDescription = intent.getStringExtra("order_description");
        }
    }

    private void requestGetToken() {
        String url = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi";
        if(isLive == "1") {
            url = "https://paymentservices.payfort.com/FortAPI/paymentApi";
        }

        RequestQueue queue = Volley.newRequestQueue(this);
        Map<String, String> params = new HashMap<>();
        params.put("service_command", "SDK_TOKEN");
        params.put("access_code", accessCode);
        params.put("merchant_identifier", merchantIdentifier);
        params.put("language", "en");
        params.put("device_id", deviceId);
        params.put("signature", hashSignature(requestPhrase + "access_code=" + accessCode + "device_id=" + deviceId + "language=enmerchant_identifier=" + merchantIdentifier + "service_command=SDK_TOKEN" + requestPhrase));
        JSONObject parameters = new JSONObject(params);
        JsonObjectRequest jsonRequest = new JsonObjectRequest(Request.Method.POST, , parameters, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                pbLoading.dismiss();
                Log.e("SUCCESS", response.toString());
                try {
                    startFortRequest(response.getString("sdk_token"));
                } catch (JSONException e) {
                    e.printStackTrace();
                    finish();
                    RNReactNativePayfortSdkModule.onFail.invoke("Error while fetching data");
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                error.printStackTrace();
                pbLoading.dismiss();
                Log.e("FAIL", error.toString());
                finish();
                RNReactNativePayfortSdkModule.onFail.invoke();
            }
        });
        queue.add(jsonRequest);
    }

    private String hashSignature(String originalString) {
        MessageDigest digest = null;
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        byte[] encodedhash = digest.digest(
                originalString.getBytes(StandardCharsets.UTF_8));
        return bytesToHex(encodedhash);
    }

    private String bytesToHex(byte[] hash) {
        StringBuffer hexString = new StringBuffer();
        for (int i = 0; i < hash.length; i++) {
            String hex = Integer.toHexString(0xff & hash[i]);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    }

    private void startFortRequest(String sdkToken) {
        FortRequest fortrequest = new FortRequest();
        fortrequest.setRequestMap(collectRequestMap(sdkToken));
        fortrequest.setShowResponsePage(true);

        try {
            FortSdk.getInstance().registerCallback(PayfortActivity.this, fortrequest, FortSdk.ENVIRONMENT.TEST, 5, fortCallback, new FortInterfaces.OnTnxProcessed() {
                @Override
                public void onCancel(Map<String, Object> requestParamsMap, Map<String,
                        Object> responseMap) {
                    Log.e("Cancelled ", responseMap.toString());
                    finish();
                    String message = "Payment has been canceled";
                    if(responseMap.get("response_message") != null && !responseMap.get("response_message").toString().equals("")) {
                        message = responseMap.get("response_message").toString();
                    }
                    RNReactNativePayfortSdkModule.onFail.invoke(message);
                }

                @Override
                public void onSuccess(Map<String, Object> requestParamsMap, Map<String,
                        Object> fortResponseMap) {
                    Log.e("Success ", fortResponseMap.toString());
                    finish();
                    RNReactNativePayfortSdkModule.onSuccess.invoke(fortResponseMap.toString());
                }

                @Override
                public void onFailure(Map<String, Object> requestParamsMap, Map<String,
                        Object> fortResponseMap) {
                    Log.e("Failure ", fortResponseMap.toString());
                    finish();
                    String message = "There is an error while process payment";
                    if(fortResponseMap.get("response_message") != null && !fortResponseMap.get("response_message").toString().equals("")) {
                        message = fortResponseMap.get("response_message").toString();
                    }
                    RNReactNativePayfortSdkModule.onFail.invoke(message);
                }

            });
        } catch (Exception e) {
            Log.e("execute Payment", "call FortSdk", e);
        }
    }

    private Map<String, Object> collectRequestMap(String sdkToken) {
        Map<String, Object> requestMap = new HashMap<>();
        requestMap.put("command", "PURCHASE");
        requestMap.put("customer_email", customerEmail);
        requestMap.put("currency", currency);
        requestMap.put("amount", amount);
        requestMap.put("language", "en");
        requestMap.put("merchant_reference", merchantReference);
        requestMap.put("customer_name", customerName);
        requestMap.put("customer_ip", customerIp);
        requestMap.put("payment_option", paymentOption);
        requestMap.put("eci", "ECOMMERCE");
        requestMap.put("order_description", orderDescription);
        requestMap.put("sdk_token", sdkToken);
        return requestMap;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        fortCallback.onActivityResult(requestCode, resultCode, data);
    }
}
