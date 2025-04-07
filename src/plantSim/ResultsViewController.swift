//
//  ResultsViewController.swift
//  plantSim
//
//  Created by user208467 on 5/3/23.
//

import UIKit


class ResultsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let cellIdentifier = "scoreCellIdentifier"
    private let dataModel = (UIApplication.shared.delegate as! AppDelegate).gameDataModel
    private let scoreManager = ScoreManager()
    
    @IBOutlet weak var commentTextView: UITextView!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreboard: UITableView!

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(scoreManager.getEntryCount(), 20)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! ScoreCell
        let entry = scoreManager.topEntries[indexPath.row]
        // Update entries in cell
        cell.update(with: entry)
        cell.sizeToFit()
        return cell
    }

    func generateGameOverComment(score: TimeInterval, isHighscore: Bool = false)->String
    {
        var comment: String
        if (!dataModel.infiniteWater)
        {
            if (isHighscore)
            {
                if (score > 60)
                {
                    comment = "A new high score? Wow!"
                } else if (score > 40)
                {
                    comment = "Oh nice, a high score!"
                } else {
                    comment = "You shouldn't be proud of this high score..."
                }
            } else {
                var comments: [String]
                if (score > 60)
                {
                    comments = ["Impressive!", "You'll make for a great gardener!", "Wow!"]
                } else if (score > 40)
                {
                    comments = ["At least you tried...?", "Better than nothing.", "You'll do better next time!"]
                } else {
                    comments = ["Did you even try?", "Disappointing.", "Yikes..."]
                }
                comment = comments.randomElement()!
            }
        } else {
            comment = "Cheaters don't get to save their scores!"
        }
        return comment
    }
    
    override func viewDidLoad() {
        let newScore = dataModel.latestScore
        timeLabel.text = ScoreManager.getTimeScoreFormatted(time: newScore)
        // Check if new high score
        let isHighscore = newScore > dataModel.highestScore
        
        commentTextView.text = generateGameOverComment(score: newScore, isHighscore: isHighscore)
        
        if (isHighscore)
        {
            // Set new highscore
            dataModel.highestScore = newScore
        }
    }
    
    // viewDidAppear is better to allow the alert to appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let newScore = dataModel.latestScore
        if (newScore > 0 && !dataModel.infiniteWater)
        {
            if (newScore > dataModel.highestScore)
            {
                dataModel.highestScore = newScore
            }
            askToAddToScoreboard(name: dataModel.cachedName, score: newScore)
        }
    }
    
    private func askToAddToScoreboard(name: String = "", score: TimeInterval)
    {
        // create alert controller
        let alertController = UIAlertController(title: "Save your score?", message: "Enter your name to add to the scoreboard. (Symbols and illegal characters will be removed)", preferredStyle: .alert)

        // add text field to alert
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Name"
            textField.text = name // If cached name then it will be suggested instead
        })

        // add cancel action to alert controller
        alertController.addAction(UIAlertAction(title: "No Thanks", style: .cancel, handler: nil))

        // add OK action to alert controller
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
            // get user input from text field
            
            if let name = alertController.textFields?.first?.text {
                let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
                let trimmedName = String(name.trimmingCharacters(in: .whitespaces)).components(separatedBy: allowedCharacterSet.inverted).joined()
                if (!trimmedName.isEmpty && self.scoreManager.addEntry(name: trimmedName, timeScore: score))
                {
                    self.scoreboard.reloadData()
                    self.dataModel.cachedName = trimmedName
                } else {
                    self.askToAddToScoreboard(score: score)
                }
            }
        }))

        // present alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    

    
    
}


class ScoreCell: UITableViewCell {
    var nameLabel: UILabel!
    var scoreLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createLabels()
    }
    
    private func createLabels()
    {
        nameLabel = UILabel(frame: CGRect(x: 16, y: 0, width: contentView.frame.width/2 - 8, height: contentView.frame.height))
        nameLabel.textAlignment = .left
        contentView.addSubview(nameLabel)
            
        scoreLabel = UILabel(frame: CGRect(x: contentView.frame.width/2 - 8, y: 0, width: contentView.frame.width/2 - 8, height: contentView.frame.height))
        scoreLabel.textAlignment = .right
        contentView.addSubview(scoreLabel)
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createLabels()
    }
        
    func update(with entry: ScoreManager.ScoreEntry) {
        // Use entries to fill in data
        nameLabel.text = entry.name
        scoreLabel.text = ScoreManager.getTimeScoreFormatted(time: entry.timeScore)
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset nameLabel and scoreLabel
        nameLabel.text = ""
        scoreLabel.text = ""
    }
    
}



