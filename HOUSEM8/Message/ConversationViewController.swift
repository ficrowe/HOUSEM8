//
//  ConversationTableViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView


class ConversationViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
  
    var conversation: Conversation?
    var messages: [MessageStruct]?
    var databaseController: DatabaseProtocol?
    var user: User?
    var conversationUsers: [User]?
    var currentMessage: Message?
    var currentMessageStruct: MessageStruct?
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        self.user = databaseController?.user
        
        //print(self.conversation, self.conversation!.messages)
        
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        if let conversation = self.conversation {
            navigationItem.title = conversation.conversationName
            self.conversationUsers = conversation.users
            
            
        }
        
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        
        
        
        
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue: .lightGray
    }
    
    func insertMessage(text: String, conversation: Conversation, sender: User) -> Message? {
        if let newMessage = databaseController?.addMessage(text: text, conversation: self.conversation!, sender: self.user!) {
           
            databaseController?.addMessageToConversation(message: newMessage, conversation: self.conversation!)
            
            
            
            
            return newMessage
        }
        return nil
    }
    
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        
        let newMessage = insertMessage(text: text, conversation: self.conversation!, sender: self.user!)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
    
    func currentSender() -> SenderType {
        return self.currentMessageStruct!.sender
    }
    
    // Function displays messages
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        self.currentMessage = self.conversation?.messages[indexPath.section]
        self.currentMessageStruct = MessageStruct(message: currentMessage!, senderID: currentMessage!.sender!.userId!, senderName: currentMessage!.sender!.getFullName())
        return self.currentMessageStruct!
    }
    
    // Returns number of sections
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if self.conversation?.messages.count == 0 {
            return 0
        }
        else {
            return self.conversation?.messages.count ?? 0
        }
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
