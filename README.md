# MSISDN Verification

## Goal

The goal is to obtain a user's MSISDN duly verified. MSISDN is a mobile phone number.

## Calling the Function

The link to the MSISDN verification page should have this format: ```verify://msisdn?success_url=<page address>```:
```
<page version="2.0">
  <div>
     To get to the next page you need to verify your phone number.
  </div>
  <navigation>
    <link pageId="verify://msisdn?success_url=authorized.jsp">Authorize</link>
  </navigation>
</page>
```

The alternative method is to specify the page attribute:
```
<page version="2.0">
  <attributes>
    <attribute name="msisdn-required" value="true"/>
  </attributes>
  <div>
    MSISDN should be here.
  </div>
</page>
```
HTTP links are also supported (see Calling plugins).

## Parameters

When using the link the following parameters are provided (in both the HTTP and verify:// formats).

|Parameters	|Mandatory	|Description											|
|:--------------|:-------------:|:----------------------------------------------------------------------------------------------|
|success_url	|Yes		|The address the user should come to after the MSISDN is verified (or in the case it is already	 verified)|
|type		|No		|Verification method. This parameter is used when the preferred verification method is not 					specified in the user's profile|

Possible values for parameter type: 
- c2s -	the default method. After entering the MSISDN the user should make a voice call to a C2S number from that mobile device,
- sms - after entering the MSISDN an SMS message with a verification code is sent to that mobile device. The user should then repeat this code in the chat, 
- ussd_dialog - after entering the MSISDN a network initiated USSD message is sent to that mobile device. The user should choose the proper menu item in the USSD page to verify the MSISDN.

