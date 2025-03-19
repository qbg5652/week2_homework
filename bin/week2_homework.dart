import 'dart:io';
import 'dart:math';

// 전역 변수로 character와 monsters 선언
Character? character;
List<Monster> monsters = [];

class Monster {
  String name;
  int health;
  int maxAttack;
  late int attack;

  // 생성자 추가
  Monster(this.name, this.health, this.maxAttack) {
    // 공격력을 1부터 maxAttack 사이의 랜덤한 값으로 설정
    final random = Random();
    this.attack = random.nextInt(maxAttack) + 1;
  }

  void attackCharacter(Character character) {
    int damage = attack;
    character.health =
        (character.health - damage).clamp(0, double.infinity).toInt();
    print('${this.name}이(가) ${character.name}에게 ${damage}의 데미지를 입혔습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack');
  }
}

class Character {
  String name;
  int health;
  int attack;
  int defense;

  // 생성자 추가
  Character(this.name, this.health, this.attack, this.defense);

  void attackMonster(Monster monster) {
    monster.health =
        (monster.health - this.attack).clamp(0, double.infinity).toInt();
    print('${this.name}이(가) ${monster.name}에게 ${this.attack}의 데미지를 입혔습니다.');
  }

  void defend(int attack) {
    int reducedDamage =
        (attack - this.defense).clamp(0, double.infinity).toInt();
    this.health =
        (this.health - reducedDamage).clamp(0, double.infinity).toInt();
    print('${this.name}이(가) 방어하여 ${this.defense}만큼 데미지를 감소시켰습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}

// 캐릭터 스탯을 불러오는 함수
void loadCharacterStats(String characterName) {
  try {
    final file = File('file/characters.txt');
    final contents = file.readAsStringSync();
    final stats = contents.split(',');
    if (stats.length != 3) throw FormatException('Invalid character data');

    int health = int.parse(stats[0]);
    int attack = int.parse(stats[1]);
    int defense = int.parse(stats[2]);

    character = Character(characterName, health, attack, defense);
    print('캐릭터 스탯을 성공적으로 불러왔습니다!');
    character?.showStatus();
  } catch (e) {
    print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}

// 몬스터들의 스택을 불러오는 함수.
void loadMonsterStats() {
  try {
    final file = File('file/monsters.txt');
    final contents = file.readAsStringSync();
    final lines = contents.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final stats = line.split(',');
      if (stats.length != 3) throw FormatException('Invalid monster data');

      String name = stats[0];
      int health = int.parse(stats[1]);
      int maxAttack = int.parse(stats[2]);

      monsters.add(Monster(name, health, maxAttack));
    }

    // 몬스터 리스트를 랜덤하게 섞기
    final random = Random();
    monsters.shuffle(random);

    // print('\n=== 몬스터 목록 ===');
    // for (var monster in monsters) {
    //   monster.showStatus();
    // }
  } catch (e) {
    print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}

void playTurn(Character player, Monster currentMonster) {
  print('\n${player.name}의 턴');
  print('행동을 선택하세요 (1: 공격, 2: 방어): ');

  String? input = stdin.readLineSync();
  if (input == '1') {
    player.attackMonster(currentMonster);
  } else if (input == '2') {
    player.defend(currentMonster.attack);
  }

  player.showStatus();
  currentMonster.showStatus();

  if (currentMonster.health > 0) {
    print('\n${currentMonster.name}의 턴');
    currentMonster.attackCharacter(player);

    player.showStatus();
    currentMonster.showStatus();
  }
}

void saveGameResult(String characterName, int remainingHealth, bool isVictory) {
  String message =
      isVictory ? '\n결과를 저장하시겠습니까? (y/n):' : '\n패배했습니다. 결과를 저장하시겠습니까? (y/n):';
  print(message);
  String? input = stdin.readLineSync()?.toLowerCase();

  if (input == 'y') {
    try {
      final file = File('file/result.txt');
      final result =
          '캐릭터 이름: $characterName\n'
          '남은 체력: $remainingHealth\n'
          '게임 결과: ${isVictory ? "승리" : "패배"}';

      file.writeAsStringSync(result);
      print('게임 결과가 저장되었습니다.');
    } catch (e) {
      print('결과 저장에 실패했습니다: $e');
    }
  }
}

void startBattle() {
  if (character == null || monsters.isEmpty) return;

  print('\n새로운 몬스터가 나타났습니다!');
  Monster currentMonster = monsters[0];
  currentMonster.showStatus();

  while (character!.health > 0 && currentMonster.health > 0) {
    playTurn(character!, currentMonster);

    if (currentMonster.health <= 0) {
      print('\n${currentMonster.name}을(를) 물리쳤습니다!');
      monsters.removeAt(0);

      if (monsters.isNotEmpty) {
        print('\n다른 몬스터와 싸우시겠습니까? (y/n):');
        String? input = stdin.readLineSync()?.toLowerCase();
        if (input == 'y') {
          print('\n새로운 몬스터가 나타났습니다!');
          currentMonster = monsters[0];
          currentMonster.showStatus();
        } else {
          saveGameResult(character!.name, character!.health, true);
          break;
        }
      } else {
        print('\n모든 몬스터를 물리쳤습니다! 게임 클리어!');
        saveGameResult(character!.name, character!.health, true);
        break;
      }
    }

    if (character!.health <= 0) {
      print('\n${character!.name}이(가) 쓰러졌습니다. 게임 오버!');
      saveGameResult(character!.name, character!.health, false);
      break;
    }
  }
}

void main(List<String> arguments) {
  print('캐릭터의 이름을 입력해주세요:');
  String characterName = '';
  while (true) {
    characterName = stdin.readLineSync() ?? '';
    if (RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(characterName)) {
      break;
    } else {
      print('한글, 영문대소문자만 입력해주세요:');
    }
  }
  print('게임을 시작합니다!');
  loadCharacterStats(characterName);
  loadMonsterStats();
  startBattle();
}
