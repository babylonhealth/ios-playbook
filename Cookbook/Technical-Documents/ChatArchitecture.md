
# The iOS Chat Architecture


## The components of Chat

### Chat SDK

- Explanation of how the Chat SDK works and an overview of the Chat V3 API
- Explanation of the concepts of Incoming and Outgoing messages
- Explanation of the concetps of chat “content” and chat “input”


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

