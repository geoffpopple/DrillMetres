@{
    SQLConfig = @{
        ServerName = #'server-name'    #update
        DatabaseName = 'catterrain'
    }

    SMTPConfig = @{
        Server = 'smtp.gmail.com'
        Port = 587
        FromEmail = 'emailadddress' #update
        Token = 'token' #update
    }

    TwilioConfig = @{
        AccountSid = 'accountsid' #update
        AuthToken = 'token' #update
        PhoneNumber = 'phonenumber' #update
        uri = "https://api.twilio.com/2010-04-01/Accounts/"
    }
}
