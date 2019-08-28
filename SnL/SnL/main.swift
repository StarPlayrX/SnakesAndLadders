import Foundation

// http://www.nepaliclass.com/wp-content/uploads/2018/04/snake-and-ladder-board-game.jpg

/// Snakes and Ladders
/// By Todd Bruss (c) 2019

/// v0.0.1 updated stats to show total ladders and snakes landed on by each player
/// v0.0.2 Added Names
/// v0.0.3 Add play-by-play game output

/// Takeaways: the player who reaches the most ladders and least amount of snakes usually wins.
/// The game loop displays a very accurate game simulation. The winner must finish the game with a perfect roll.
/// Oddity, when this code is run in Playgrounds, its turn_counter is not accurate.
/// When run in Xcode or command line, it displays correctly
/// This code should run on Mac as well as Linux. Requirements Swift 5

//Here we need to have a Random function that it supports
func rollDie(_ min: Int, _ max: Int) -> Int {
    #if os(Linux)
    return Int(random() % max) + min //Linux only
    #else
    return Int.random(in: min...max) //Swift 5 for macOS and iOS
    #endif
}

// snakes and ladders game function, default die is 6
func snakesAndLadders(die_max: Int = 6, player1_name: String = "Ricky", player2_name: String = "Bobby") {
    
    let divider = "-----------------------------------------"
    // protect against a single sided die
    guard die_max > 1 else {
        print("Sorry, a single sided die cannot used in this game.\r\nIt causes an infinite loop to occur and is not allowed.")
        return
    }
    
    // protect against a die greater than 64
    guard die_max <= 64 else {
        print("Sorry, a die larger than 64 is not allowed.")
        return
    }
    
    // tell the user how big the die is
    print("Using a \(die_max) sided die.\r\n")
    
    var LaddersDict = [Int:Int]()
    var SnakesDict  = [Int:Int]()
    
    /// The Game Board has 6 Ladders
    /// Its key is the landed on position
    /// Its value is the upgraded to position
    
    LaddersDict[80] = 99   //1
    LaddersDict[2]  = 38   //2
    LaddersDict[4]  = 14   //3
    LaddersDict[9]  = 31   //4
    LaddersDict[33] = 85   //5
    LaddersDict[52] = 88   //6
    
    /// The Game Board has 5 Snakes
    /// Its key is the landed on position
    /// Its value is the downgraded to position
    
    SnakesDict[62] = 57  //1
    SnakesDict[98] = 8   //2
    SnakesDict[56] = 15  //3
    SnakesDict[92] = 53  //4
    SnakesDict[51] = 11  //5
    
    /// For this version our game has two players
    /// The goal is to simulate and entire game until a winner is declared
    
    let start_position  = 1
    let finish_position = 100
    
    /// This lets up reuse our stats for other areas in our app and we only need to define it once.
    typealias stats = (name:String, position:Int,snakes:Int,ladders:Int)
    
    var PlayerDict = [Int:(stats)]()
    
    PlayerDict[1] = (name:player1_name, position: start_position, snakes:0, ladders:0)
    PlayerDict[2] = (name:player2_name, position: start_position, snakes:0, ladders:0)
    
    /// Determine's which player should go first
    /// Uses a coin toss randomize function.
    /// It works on Linux and macOS / iOS
    let coin_toss = rollDie(1,2)
    
    /// Since our loop starts out with the inverse, We invert this input (negative x negative = positive)
    /// Player1 turn properly determines if player 1 or 2 goes first
    var player1_turn = coin_toss == 1 ? false : true
    
    //count how many turns it took to reach a victor!
    var turn_counter = 0
    
    //keeps taps on which player is playing
    var current_player = 1
    
    // game constants
    let increment = 1
    let die_min = 1
    
    /// In this loop, I cut it down it to as few operations as possible (for scalability over time)
    /// Also keep the code as readable as possible that is in the loop
    /// Game Loop: Play until we have an absolute winner! First 1 to square 100 wins. Winner must have a perfect roll.
    while PlayerDict[1]?.position ?? 1 < finish_position &&
        PlayerDict[2]?.position ?? 1 < finish_position {
            
            print(divider)
            turn_counter += increment
            
            //alternates between player 1 and player 2
            player1_turn = !player1_turn
            
            current_player = player1_turn ? 1 : 2
            
            //Update player position with new roll
            let roll = rollDie(die_min, die_max)
            
            if let cp = PlayerDict[current_player] {
                print("\(cp.name) rolls \(roll),")
            }
            
            PlayerDict[current_player]?.position += roll
            
            var square99 = false
            if let position = PlayerDict[current_player]?.position {
                
                //if >100 move the player back, we are expecting a perfect roll
                if position > finish_position {
                    
                    /// Reverts the player's position
                    /// Our game rule is the player must have an exact roll
                    /// This makes the game more interesting with more chances to
                    /// 1. player can land on a snake near the end
                    /// 2. the opposing player has a chance to catch up
                    PlayerDict[current_player]?.position -= roll
                    
                    if let currentPlayer = PlayerDict[current_player] {
                        print("\(currentPlayer.name)'s roll lands past 100,\r\nmoves back to previous spot: \(currentPlayer.position).")
                        square99 = true
                    }
                }
                
                
                //the player landed on a ladder base (yay!)
                if let ladder_destination = LaddersDict[position] {
                    
                    if let currentPlayer = PlayerDict[current_player]{
                        print("moves to square \(currentPlayer.position),")
                    }
                    
                    print("lands on a ladder,")
                    
                    PlayerDict[current_player]?.ladders += increment
                    PlayerDict[current_player]?.position = ladder_destination
                    
                    if let currentPlayer = PlayerDict[current_player] {
                        print("climbs to \(currentPlayer.position).")
                    }
                    
                    //the player landed on a Snake head (ouch! I got bit)
                } else if let snake_destination = SnakesDict[position] {
                    
                    if let currentPlayer = PlayerDict[current_player] {
                        print("moves to square \(currentPlayer.position),")
                    }
                    
                    
                    print("gets bit by a snake,")
                    
                    PlayerDict[current_player]?.snakes += increment
                    PlayerDict[current_player]?.position = snake_destination
                    
                    if let currentPlayer = PlayerDict[current_player] {
                        print("slides down to \(currentPlayer.position).")
                    }
                } else if !square99 {
                    if let currentPlayer = PlayerDict[current_player] {
                        print("moves to square \(currentPlayer.position).")
                    }
                }
            }
            
    }
    
    let playerCount = PlayerDict.count
    let playerLoop = Array(1...playerCount)
    
    var standings = [Int]()
    
    for p in playerLoop {
        if let player = PlayerDict[p] {
            standings.append(player.position)
        }
    }
    
    var winningPlayer   = 0
    var winningScore    = 0
    
    //determine winner
    for i in (0..<playerCount) {
        if standings[i] > winningScore {
            winningScore = standings[i]
            winningPlayer = i + increment
        }
    }
    
    //And the winner is!
    print(divider)
    if let wp = PlayerDict[winningPlayer] { //, let lp = PlayerDict[losingPlayer] {
        print("After \(turn_counter) turns: \(wp.name) wins!")
    }
    
    
    print(divider)
    
    //prep for multi player
    for p in playerLoop {
        if let player = PlayerDict[p] {
            //additional stats
            print("\(player.name) total ladders : \(player.ladders)")
            print("\(player.name) total snakes  : \(player.snakes)")
            print(divider)
        }
    }
    
    if let ct = PlayerDict[coin_toss] {
        print("\(ct.name) went first.")
    }
    
    print(divider)
    
    return
}

//run the program

//pick which sided die (2-64)
snakesAndLadders(die_max: 6, player1_name: "Bob", player2_name: "Todd")

exit(0) //may not be needed for this environment. Including it as a safety net.
