
# The iOS Chat Architecture


## The components of Chat

### Chat SDK and API

#### Chat SDK

The Chat SDK is an SDK that provides access to the features of the [Chat V3 API](https://developers.babylonpartners.com/rest-apis/guides/chatbot). The Chat API is used for conversational flows such as Triage, Healthcheck and Assistant. 

The top level object in the Chat SDK is the `ChatAPI` which allows you start a new `ConversationSession` or retrieve an existing one.

With a `ConversationSession` you can access the current `Chat` which contains the status of the chat and all its messages, plus the current `ChatInput` type that should be displayed to the user.

The `ConversationSession` also allows you to check if `isUndoAvailable` and `undo` the previous message, and also request `inputSuggestions` for the current conversation. Input suggestions are used for the auto-suggest feature of the symptom selector, and potentially in other free text entry scenarios.

#### Incoming and Outgoing messages

A `Chat` in a `ConversationSession` is essentially just an array of `Chat.Message`s. In the Chat API no distinction is made between "incoming" and "outgoing" messages, but in the Chat SDK it is useful to make that distinction, as they actually serve quite different purposes. In the SDK the term "Incoming" is used to refer to messages that come from the server and "Outgoing" for messages that were sent by the user.

When decoding a `Chat.Message` from the API, if the `sender` of the message is `babylon` then it is decoded as a `Chat.Message.Incoming`, if it's `user` then it's decoded as a `Chat.Message.Outgoing`.

An Incoming message can have the following different types of content:

* Text: by far the majority of incoming messages are just text.
* Doctor Response: the response of a doctor to a question the user has sent using the "Ask a clinician" flow.
* Leaflet: details of an NHS leaflet to display to the user.
* Notice: details of a privacy notice to display to the user.
* Diagnosis: details of a Triage diagnosis or outcome to display to the user.

An Outgoing message can have the following types of content:

* Text: used to display the response of a user to a question that was asked. The majority of outgoing messages have text content.
* Location: a name and location coordinates which represent a location (e.g. a hospital or pharmacy) which the user selected in response to a question.
* Image: an image which the user has sent to the server, usually as part of the "Ask a clinician" flow.

##### Message display considerations

When displaying the chat conversation in a UI, depending on how the UI is designed, it can be useful to know that it is possible to have a sequence of more than one Incoming message, with no Outgoing message in between. For some forms of UI it makes sense to agglomerate a sequence of Incoming messages into a single message to be displayed to the user.

### Chat Input Types

When a chat conversation is waiting for user input, there are several types of input that can be shown to the user. The input for the current state of the chat is stored in the `Chat`'s `inputType: InputType` property which maps to API input types. A much more useful property is the `input: ChatInput` property in `Chat` which is a more closely maps to how a UI might represent a given `InputType`, and also each type has a `sender` closure which can be used to send the chosen input to the server.

The different types of input are:

* Text: free text input, although `TextInputParameters` can contain additional information as to how the to display the text input.
* Date: date input, can have minimum and maxium requirements.
* Single option: a list of `Option`s from which the user has to choose one.
* Multiple option: a list of `Option`s from which the user can choose one or more.
* Text and images: allow the user to provide text and images. This is exclusively used for the "Ask a Clinician" flow.
* Phone: a phone number.
* Symptom: a symptom that the user has chosen from a list of symptoms provided by the server, usually via autocomplete suggestions.
* Retry: indicate an error condition to the user, allowing them to retry the previous message.
* No Input: a state in which no input is require.


### Chat View Models



Explanation of how amd why chat is broken into 3 separate view models.

- Explain responsibilities of the `ChatViewModel` 
- Explain the responsibilities of the `ChatContentViewModel` 
- Explain the responsibilities of the `ChatInputViewModel` 


### Chat rendering strategies

Difference between the `.threaded` and `.singleMessage` strategies and which is used where.

`.singleMessage` has a single renderer (`FocusedChatRenderer) `and `.threaded` has a renderer for the content (`ChatContentRenderer`), input (`ChatInputRenderer`) and the root (containing) screen (`ChatRootRenderer`) . Explain how these work differently. They are both custom renderers, not subclasses of `BoxRenderer` .

Explanation of the different view controllers used (`FocusedChatViewController`, `ChatRootViewController` and `ChatContentViewController`) 


### Using a custom ChatAPI implementation

The Chat architecture can be re-used by any feature that has a conversational “flow” type UI, it is not tied to the Chatbot API.  Show how consultation feedback is an example of this.

