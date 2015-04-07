//
//  ChatLeftAudioCell.swift
//  Yep
//
//  Created by NIX on 15/4/2.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

class ChatLeftAudioCell: UICollectionViewCell {

    var message: Message!

    var audioPlayedDuration: Double = 0 {
        willSet {
            println("audioPlayedDuration: \(newValue)")

            configureSampleView()
        }
    }


    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarImageViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var bubbleImageView: UIImageView!
    
    @IBOutlet weak var sampleView: SampleView!
    @IBOutlet weak var sampleViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var audioDurationLabel: UILabel!

    @IBOutlet weak var playButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageViewWidthConstraint.constant = YepConfig.chatCellAvatarSize()
        
        bubbleImageView.tintColor = UIColor.leftBubbleTintColor()

        sampleView.sampleColor = UIColor.leftWaveColor()

        audioDurationLabel.textColor = UIColor.blackColor()

        playButton.userInteractionEnabled = false
        playButton.tintColor = UIColor.darkGrayColor()
    }

    func configureWithMessage(message: Message, audioPlayedDuration: Double) {

        self.message = message

        self.audioPlayedDuration = audioPlayedDuration

        if let sender = message.fromFriend {
            AvatarCache.sharedInstance.roundAvatarOfUser(sender, withRadius: YepConfig.chatCellAvatarSize() * 0.5) { roundImage in
                dispatch_async(dispatch_get_main_queue()) {
                    self.avatarImageView.image = roundImage
                }
            }
        }

        configureSampleView()
    }

    func configureSampleView() {
        if !message.metaData.isEmpty {

            if let data = message.metaData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                if let metaDataDict = decodeJSON(data) {

                    if let audioSamples = metaDataDict["audio_samples"] as? [CGFloat] {
                        sampleViewWidthConstraint.constant = CGFloat(audioSamples.count) * (YepConfig.audioSampleWidth() + YepConfig.audioSampleGap()) - YepConfig.audioSampleGap() // 最后最后一个 gap 不要
                        sampleView.samples = audioSamples

                        if let audioDuration = metaDataDict["audio_duration"] as? Double {
                            audioDurationLabel.text = NSString(format: "%.1f\"", audioDuration) as String

                            sampleView.progress = CGFloat(audioPlayedDuration / audioDuration)

                        } else {
                            sampleView.progress = 0
                        }
                    }
                }

            } else {
                sampleViewWidthConstraint.constant = 15 * (YepConfig.audioSampleWidth() + YepConfig.audioSampleGap())
                audioDurationLabel.text = ""
            }
        }
    }
}
