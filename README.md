# Call Load Tester
A load tester that generates calls using Twilio

## Installation
1. [Install Ruby 2.6.1](https://www.ruby-lang.org/en/documentation/installation/)
2. Open a terminal in the folder with this code in it
3. Execute the following commands:
   
    ```
    gem install bundler
    bundle install
    ```


## Twilio Setup
1. [Buy a number](https://support.twilio.com/hc/en-us/articles/223135247-How-to-Search-for-and-Buy-a-Twilio-Phone-Number-from-Console) or [verify a number](https://support.twilio.com/hc/en-us/articles/223180048-Adding-a-Verified-Phone-Number-or-Caller-ID-with-Twilio) you already own. This will be the number you use for the caller ID.
2. Create the call behavior [TwiML](https://www.twilio.com/docs/voice/twiml) in a [TwiML Bin](https://www.twilio.com/docs/runtime/tutorials/twiml-bins). Here is a simple TwiML you can use that will repeat the same message infinitly until the call is ended.
   ```
    <?xml version="1.0" encoding="UTF-8"?>
    <Response>
       <Say loop="0">This is a test call</Say>
    </Response>
    ```
3. Save the TwiMLBin
4. Copy the URL of the TwiMLBin
5. Copy your [Twilio Account SID and Auth Token](https://support.twilio.com/hc/en-us/articles/223136027-Auth-Tokens-and-How-to-Change-Them)
6. [Store the credentials securely](https://www.twilio.com/docs/usage/secure-credentials) in your local terminal environment:
   ```
   echo "export TWILIO_ACCOUNT_SID='ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'" > twilio.env
   echo "export TWILIO_AUTH_TOKEN='your_auth_token'" >> twilio.env
   source ./twilio.env
   ```

## Usage
#### General
1. Use the start.rb script to create calls to a destination number. The script will gradually increase the number of concurrent calls.
2. Monitor the system you are testing
3. Use the end.rb script to hang up the calls you created in step 1.

#### Starting calls
The start.rb script will start calls at a maximum calls per second you specify.
The script can also, optionally end the calls after it starts them all.

The script writes the SIDs of the calls it starts to a file in the same directory as the script called `call_sids_[TIMESTAMP].csv`.
This file can be passed to the end.rb script to end the calls. 

> :warning: **It is recommend that you use the --dry_run flag to test your configuration before placing actual calls.**

```
ruby start.rb ARGUMENTS

-c, --caller_id PHONE_NUMBER     The caller ID to use for the calls
-d, --destination PHONE_NUMBER   The number to call.
    --call_count NUMBER          The number of calls to start.
    --cps NUMBER                 Maximum number of calls to start per second.
-t, --twiml URL                  The URL for the Twillio Markup Language that controls the call behavior.
    --dry_run
-e, --end_calls BOOLEAN
-h, --hold SECONDS                 Number of seconds to wait before hanging up the calls.
    --sid SID                    Twilio account SID. Recommend using ENV variable TWILIO_ACCOUNT_SID instead of command line argument.
    --token TOKEN                Twilio API authorization token. Recommend using ENV variable TWILIO_AUTH_TOKEN instead of command line argument
```

#### Ending calls
The end.rb script will end calls whose SIDs are in the file you provide to it. Ending the calls is idempodent. You may pass the same SIDs to the end.rb script multiple times without causing problems with Twilio.

```
ruby end.rb ARGUMENTS

-f, --file FILE_PATH             Path to a file containing the call SIDs to end
    --sid SID                    Twilio account SID. Recommend using ENV variable TWILIO_ACCOUNT_SID instead of command line argument.
    --token TOKEN                Twilio API authorization token. Recommend using ENV variable TWILIO_AUTH_TOKEN instead of command line argument

```

## Rate Limiting
> :warning: **WARNING:** You can easily overwhelm and crash a phone system with this script. Start with a low call per second (CPS) limit and work your way up.

The start.rb script limits the maximum number of calls that can be started each second to the value you provide in the --cps argument. 

However, the call starts are not evenly distributed accross each second.
The script will start the calls as fast as it can, until it hits the CPS limit for a second.
Then it will stop until the next second begins.
This means that, at high CPS rates, the call starts can be very bursty.

The maximum CPS rate is limited by the response time of the Twilio API.
