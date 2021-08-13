//
//  InvitationTableViewCell.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 1/7/21.
//

import UIKit

class InvitationTableViewCell: UITableViewCell {

    @IBOutlet weak var invitationField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkField() -> Bool {
        if invitationField.hasText {
            return true
        }
        return false
    }
    
    func getText() -> String? {
        return self.invitationField.text
    }

}
