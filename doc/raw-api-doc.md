<link href="markdown.css" rel="stylesheet"></link>

# Nearspeak API Documentation (Version: 0.1.0)

- JSON Keys marked with "*" are mandatory, if there are default values it's noted with [default: ]

## Login

### POST /api/v1/login/getAuthToken

- Returns an authentication token, which is required for other api methods.

#### Example Request

    {
      *"email": "user@example.com",
      *"password": "supersecretpassword",
    }

#### Example curl command

    curl -XPOST -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/login/getAuthToken -d '{ "email": "demo@example.com", "password": "secret" }'

#### Example Success Response

	{  
	   "auth_token":"urjufyi4MFDXyitZM9Tx"
	}
  
#### Example Error Response

	  {
	      "error": {
	          "message": "User not found.",
	          "code": "InvalidRequest"
	      }
	  }

### POST /api/v1/login/signInWithFacebook

- Sign in via facebook authentication token.

#### Example Request

    {
      *"auth_token" : "zeHDoz4ixg9BNi5mvZmB"
    }

### POST /api/v1/login/signOut

- Sign out the user.

#### Example Request

    {
      *"email": "user@example.com",
      *"auth_token": "zeHDoz4ixg9BNi5mvZmB"
    }

#### Example curl command

    curl -XPOST -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/login/signOut -d '{ "email": "user@example.com", "auth_token": "urauMyiM2F3XydtKM9Td" }'

#### Example Success Response

	{  
	   "message":"Logout was successful.",
	   "code":"OK"
	}
  
#### Example Error Response

	  {  
	     "error":{  
	        "message":"Logout went wrong.",
	        "code":"LogoutError"
	     }
	  }

## Tags

### POST /api/v1/tags/create

- Creates a new tag. If a valid _auth\_token_ is given, the tag is connected to the customer.

#### Parameters
- **lang**  		```required```	The language code if the new text. **Example Values:** ```de```
- **purchase_id**	```required```	The purchase ID from the Windows Phone Store. **Example Values:** ```4ea93515-5a84-4add-bf81-293b306b968f```
- **text**			```required```	The new text. **Example Values:** ```What does the fox say.```
- **auth_token** 	```optional```	The authentication token. **Example Values:** ```zeHDoz4ixg9BNi5mvZmB```
- **name**  		```optional```	The name for the tag. **Example Values:** ```Entrance door```
- **gender**		```optional```	Choose m for male or f for female. **Example Values:** ```m```
- **hardware_id**	```optional```	The hardware identifier. **Example Values:** ```0433288AA62781```
- **hardware_type**	```optional```	The hardware type. **Valid Values:** ```nfc, ble-beacon, qr```
- **major**			```optional```	The bluetooth beacon major id. **Valid Values:** ```1234```
- **minor**			```optional```	The bluetooth beacon minor id. **Valid Values:** ```5678```
- **parent_id**		```optional```	The id of the parent tag. **Example Values:** ```139```
- **lat**			```optional```	The latitude of the hardware. **Example Values:** ```47.42307```
- **lon**			```optional```	The longitude of the hardware. **Example Values:** ```15.26703```

#### Example Request

    {
      "auth_token": "zeHDoz4ixg9BNi5mvZmB",
	  *"lang": "de",
	  *"purchase_id": "4ea93515-5a84-4add-bf81-293b306b968f",
	  *"text": "What does the fox say"
    }

#### Example curl command

    curl -XPOST -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/tags/create -d '{ "auth_token": "urjuMyiMMFEXyitKMaFx", "purchase_id": "4ea932415-5e84-4aff-bf81-293b306b9463f", "text": "Whats up", "lang": "de" }'

#### Example Success Response

	{  
	   "tags":[  
	      {  
	         "id":175,
	         "tag_identifier":"c29483d3e4de",
	         "gender":"m",
	         "translation":{  
	            "text":"Whats up",
	            "lang":"de"
	         }
	      }
	   ]
	}
  
#### Example Error Response

	  {  
	     "error":{  
	        "message":"Request values are missing",
	        "values":[  
	           "lang"
	        ],
	        "code":"InvalidRequest"
	     }
	  }

### POST /api/v1/tags/addHardwareIdToTag

- Add a hardware identifier to a nearspeak tag.

#### Parameters
- **id**			```required```	The Nearspeak ID. **Example Values:** ```58f46cfe90d5```
- **hardware_id**	```required```	The hardware identifier. **Example Values:** ```0433288AA62781```
- **hardware_type**	```required```	The hardware type. **Valid Values:** ```nfc, ble-beacon, qr```
- **auth_token** 	```optional```	The authentication token. **Example Values:** ```zeHDoz4ixg9BNi5mvZmB```
- **major**			```optional```	The bluetooth beacon major id (Required if type id ble_beacon). **Example Values:** ```1234```
- **minor**			```optional```	The bluetooth beacon minor id (Required if type id ble_beacon). **Example Values:** ```5678```
- **lat**			```optional```	The latitude of the hardware. **Example Values:** ```47.42307```
- **lon**			```optional```	The longitude of the hardware. **Example Values:** ```15.26703```

#### Example curl command

    curl -XPOST -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/tags/addHardwareIdToTag -d '{ "auth_token": "urjuMyiMMFEXyitKMaFx", "id": "4ea93241563f", "hardware_id": "EFC-2", "hardware_type": "qr" }'

#### Example Success Response

	{  
	   "tags":[  
	      {  
	         "id":175,
	         "tag_identifier":"c29483d3e4de",
	         "gender":"m",
	         "translation":{  
	            "text":"Whats up",
	            "lang":"de"
	         }
	      }
	   ]
	}
  
#### Example Error Response

	  {  
	     "error":{  
	        "message":"Request values are missing",
	        "values":[  
	           "lang"
	        ],
	        "code":"InvalidRequest"
	     }
	  }

### GET /api/v1/tags/show

- Shows a tag via the Nearspeak ID.

#### Parameters
- **id**	```required```	The Nearspeak ID. **Example Values:** ```58f46cfe90d5```
- **lang**	```optional```	The requested language. **Example Values:** ```en```

#### Example curl command

    curl -XGET -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/tags/show -d '{ "id": "urjuMyiMMFEXyitKMaFx" }'

#### Example Success Response

	{  
	   "tags":[  
	      {  
	         "id":123,
	         "tag_identifier":"c2b5cd49a8ad",
	         "description":"Summer Party",
	         "name":{  
	            "text":"Store Screenshot 2 - Holidays",
	            "lang":"de"
	         },
	         "gender":"m",
	         "image_url":"http://nearspeak.at/images/2-holidays.jpg",
	         "text_url":"http://www.nearspeak.at/",
	         "translation":{  
	            "text":"Win your next holiday trip!",
	            "lang":"en"
	         }
	      }
	   ]
	}
  
#### Example Error Response

	  {  
	     "error":{  
	        "message":"Tag not found",
	        "code":"InvalidRequest"
	     }
	  }

### GET /api/v1/tags/showByHardwareId

- Shows a tag via the hardware identifier.

#### Parameters
- **id**	```required```	The hardware identifier. **Example Values:** ```0433288AA62780```
- **type**	```required```	The hardware type. **Example Values:** ```nfc```
- **major**	```optional```	The bluetooth beacon major id (Required if type id ble_beacon). **Example Values:** ```1234```
- **minor**	```optional```	The bluetooth beacon minor id (Required if type id ble_beacon). **Example Values:** ```5678```
- **lang**	```optional```	The requested language. **Example Values:** ```en```
- **lat**	```optional```	The latitude of the hardware. **Example Values:** ```47.42307```
- **lon**	```optional```	The longitude of the hardware. **Example Values:** ```15.26703```

#### Example curl command

    curl -XGET -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/tags/showByHardwareId -d '{ "id": "048F7A81A72780", "type": "nfc" }'

#### Example Success Response

	{  
	   "tags":[  
	      {  
	         "id":55,
	         "tag_identifier":"2fdcb41bdad4",
	         "name":{  
	            "text":"Multi NFC Tag",
	            "lang":"de"
	         },
	         "image_url":"http://heidicohen.com/wp-content/uploads/Big-Fat-Cat-.jpg",
	         "text_url":"www.appaya.at",
	         "translation":{  
	            "text":"das ist ein mehrfach online Pack",
	            "lang":"de"
	         },
	         "hardware":[  
	            {  
	               "type":"nfc",
	               "identifier":"048F7A81A72780"
	            },
	            {  
	               "type":"nfc",
	               "identifier":"678D3200"
	            },
	            {  
	               "type":"nfc",
	               "identifier":"04DB6D89A72780"
	            }
	         ]
	      }
	   ]
	}
  
#### Example Error Response

	  {  
	     "error":{  
	        "message":"Tag not found",
	        "code":"InvalidRequest"
	     }
	  }

### GET /api/v1/tags/showMyTags

- Shows all your Nearspeak tags.

#### Example Request

    {
      *"auth_token": "afggwwUE7324422"
    }

#### Example curl command

    curl -XGET -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/tags/showMyTags -d '{ "auth_token": "048F7A81A72780" }'

#### Example Success Response

	{  
	   "tags":[  
	      {  
	         "id":55,
	         "tag_identifier":"2fdcb41bdad4",
	         "name":{  
	            "text":"Multi NFC Tag",
	            "lang":"de"
	         },
	         "image_url":"http://heidicohen.com/wp-content/uploads/Big-Fat-Cat-.jpg",
	         "text_url":"www.appaya.at",
	         "translation":{  
	            "text":"das ist ein mehrfach online Pack",
	            "lang":"de"
	         },
	         "hardware":[  
	            {  
	               "type":"nfc",
	               "identifier":"048F7A81A72780"
	            },
	            {  
	               "type":"nfc",
	               "identifier":"678D3200"
	            },
	            {  
	               "type":"nfc",
	               "identifier":"04DB6D89A72780"
	            }
	         ]
	      }
	   ]
	}
  
#### Example Error Response

	  {  
	     "error":{  
	        "message":"User not found.",
	        "code":"UserNotFound"
	     }
	  }

### GET /api/v1/tags/supportedLanguageCodes

- Shows all supported translation languages by Bing Translate.

#### Example curl command

    curl -XGET -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/tags/supportedLanguageCodes

#### Example Success Response

	{  
	   "language_codes":[  
	      "ar",
	      "bg",
	      "ca",
	      "zh-CHS",
	      "zh-CHT",
	      "cs",
	      "da",
	      "nl",
	      "en",
	      "et",
	      "fi",
	      "fr",
	      "de",
	      "el",
	      "ht",
	      "he",
	      "hi",
	      "mww",
	      "hu",
	      "id",
	      "it",
	      "ja",
	      "tlh",
	      "tlh-Qaak",
	      "ko",
	      "lv",
	      "lt",
	      "ms",
	      "mt",
	      "no",
	      "fa",
	      "pl",
	      "pt",
	      "ro",
	      "ru",
	      "sk",
	      "sl",
	      "es",
	      "sv",
	      "th",
	      "tr",
	      "uk",
	      "ur",
	      "vi",
	      "cy"
	   ]
	}

### GET /api/v1/tags/supportedBeaconUUIDs

- Shows all supported and active iBeacons UUIDs.

#### Example curl command

    curl -XGET -H 'Content-Type: application/json' http://nearspeak.cloudapp.net/api/v1/tags/supportedBeaconUUIDs

#### Example Success Response

	{  
	   "uuids":[  
	      "699EBC80E1F311E39A0F0CF3EE3BC012",
	      "CEFCC021E45F4520A3AB9D1EA22873AD",
	      "F7826DA6-4FA2-4E98-8024-BC5B71E0893E"
	   ]
	}
