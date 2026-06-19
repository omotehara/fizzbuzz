# 定数クラス
class Constants
  # こうげきタイプ
  ATTACK_TYPE_NORMAL = 1 # 通常攻撃
  ATTACK_TYPE_MAGIC = 2  # 魔法攻撃
  ATTACK_VARIANCE = 3  # こうげき力の触れ幅
  HP_MIN = 0  # HPが最小値

  # 行動選択
  ACTION_ATTACK = 1  # こうげき
  ACTION_ESCAPE = 2  # 逃げる
end

# キャラクタークラス
class Character
  # ステータスを管理するアクセサ
  attr_accessor :name, :hp, :attack_damage, :attack_type, :is_player, :is_alive

  # キャラクターの初期設定
  def initialize(name, hp, attack_damage, attack_type, is_player = false)
    @name = name                    # キャラクター名
    @hp = hp                        # HP
    @attack_damage = attack_damage  # こうげき力
    @attack_type = attack_type      # こうげきタイプ
    @is_player = is_player          # プレイヤーフラグ
    @is_alive = true                # 生存フラグ
  end

  
  # ダメージ計算処理
  def calculate_damage
      # ランダムダメージ(こうげき力±振れ幅)
    rand(@attack_damage - Constants::ATTACK_VARIANCE..@attack_damage + Constants::ATTACK_VARIANCE)
  end

  # ダメージ反映処理
  def receive_damage(damage)
    @hp -= damage  # ダメージ処理

    # 戦闘不能処理
    if @hp <= Constants::HP_MIN
      @hp = Constants::HP_MIN   # HPが0未満にならないよう調整
      @is_alive = false         # 生存フラグを下ろす
    end
  end

end

# ゲームを進行するクラス
class Game
  # ゲームの初期設定を行う
  def initialize
    @escape_flg = false  # 逃げるフラグ

    puts "↓勇者の名前を入力してください↓"
    hero_name = gets.chomp  # ユーザの入力を取得

    # キャラクターの作成
    @heroes = create_heroes(hero_name)
    @monsters = create_monsters

    # キャラクター情報を表示
    display_character_info(@heroes)
    display_character_info(@monsters)
  end
    # ゲーム進行
  def start
    round = 0   # ラウンド数

    puts "\n◆◆◆ モンスターが現れた！ ◆◆◆"

    loop do
        # ラウンド数
        round += 1
        puts "\n=== ラウンド #{round} ==="
       
        # 最新ステータスの表示
        display_status(@heroes)    # 勇者パーティ表示
        display_status(@monsters)  # モンスターパーティ表示

        # 勇者パーティのターン処理
        process_heroes_turn()
        return if @escape_flg  # 逃げた場合はループを抜ける

        # モンスターのターン処理
        process_monsters_turn()
    end
  end
    
  
  private

  # 勇者パーティを作成
  def create_heroes(hero_name)
    [
      Character.new(hero_name, 30, 6, Constants::ATTACK_TYPE_NORMAL, true),  # プレイヤーが操作する勇者
      Character.new('魔法使い', 20, 8, Constants::ATTACK_TYPE_MAGIC)          # 魔法使い(CPU)
    ]
  end

  # モンスターを作成
  def create_monsters
    [
      Character.new('オーク', 30, 8, Constants::ATTACK_TYPE_NORMAL),    # オーク(CPU)
      Character.new('ゴブリン', 25, 6, Constants::ATTACK_TYPE_NORMAL)   # ゴブリン(CPU)
    ]
  end

  # キャラクター情報を表示するメソッド
  def display_character_info(characters)
    characters.each { |character|
        puts "\nキャラクター名：#{character.name}"
        puts "HP：#{character.hp}"
        puts "こうげき力：#{character.attack_damage}"
        puts "こうげきタイプ：#{character.attack_type}"
        puts "プレイヤーフラグ：#{character.is_player}"
        puts "生存フラグ：#{character.is_alive}"
    }
  end

  # キャラクターのステータスを表示する
  def display_status(characters)
    characters.each { |character|
    puts "・【#{character.name}】 HP：#{character.hp} こうげき力：#{character.attack_damage}"
  }
  end

  # 勇者のターンを処理する
   def process_heroes_turn
     @heroes.each do |character|    # @heroesの各オブジェクトを呼び出す
     next unless character.is_alive    # is_aliveがfalseなら以下の処理を行わない
     loop do
      puts "\n↓行動を選択してください↓"
      puts "【#{Constants::ACTION_ATTACK}】こうげき"
      puts "【#{Constants::ACTION_ESCAPE}】逃げる"
      choice = gets.to_i  # 行動の入力を整数で受け付ける

      # 行動
      case choice
      when Constants::ACTION_ATTACK
       # こうげき 
       execute_attack(@heroes, @monsters) # (行動するキャラクター, こうげき対象)
      when Constants::ACTION_ESCAPE
        # 逃げる
        execute_escape(@heroes[0])             # 逃げる処理
        return                              # メソッドを抜ける
      else
        # 無効な選択
        puts "無効な選択肢です"
      end
     end
    end

  # モンスターのターンを処理する
   def process_monsters_turn
     execute_attack(@heroes, @monsters) # (行動するキャラクター, こうげき対象) 
   end

   # こうげき共通
    def execute_attack(attackers, defenders)  # (行動するキャラクター, こうげき対象)
    attackers.each{ |attacker|
        defenders.each{ |defender|
            # こうげきメッセージ(タイプ別)
            case attacker.attack_type
                when Constants::ATTACK_TYPE_NORMAL
                puts "#{attacker.name}のこうげき！"
                when Constants::ATTACK_TYPE_MAGIC
                puts "#{attacker.name}の魔法こうげき！"
            end
            # ダメージ処理
            damage = attacker.calculate_damage()  # ダメージ計算
            defender.receive_damage(damage)       # ダメージ反映

            puts "#{defender.name} に #{damage} のダメージ！"  # ダメージ処理
            puts "#{defender.name} はたおれた！" unless defender.is_alive # 戦闘不能メッセージ 
         }
    }
     
    end
    
    
    # 逃げる
    def execute_escape(character)
     puts "#{character.name} は逃げ出した！"
     @escape_flg = true  # 逃げるフラグを立てる
    end

end



# ゲーム開始
game = Game.new
game.start()


# エラーあります