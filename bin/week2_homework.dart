import 'dart:io';
import 'dart:math';

// 전역 변수로 character와 monsters 선언
Character? character;
List<Monster> monsters = [];

// 아이템 사용과 턴카운트를 위해 전역 변수 선언
bool usedItem = false;
int turnCount = 0;

class Monster {
  String name;
  int health;
  int maxAttack;
  int defense = 0;
  late int attack;

  // 생성자 추가
  Monster(this.name, this.health, this.maxAttack) {
    // 공격력을 1부터 maxAttack 사이의 랜덤한 값으로 설정
    final randomAttack = Random();
    // 0부터 maxAttack의 -1까지 공격력임. 그렇기에 +1을 해줘야 maxAttack까지 공격력이 나옴.
    // nextInt()는 0이상, bound 미만의 난수를 생성함. 즉, 0부터 maxAttack - 1까지의 난수를 생성함.
    this.attack = randomAttack.nextInt(maxAttack) + 1;
  }

  void attackCharacter(Character character) {
    int damage = attack;
    // clamp() 함수는 주어진 값을 범위 내에 제한함. 최소가 0, 최대가 double.infinity.(무한대. 최대체력을 의미함.)
    // double.infinity로 최대값을 넣고, 이는 double형 값이므로 toInt()로 int형으로 변환해줌.
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
    if (stats.length != 3) throw FormatException('파일 형식을 확인해주세요.');

    // 캐릭터 스탯불러오기. int.parse()로 문자를 int형으로 변환. stats[0]은 체력, stats[1]은 공격력, stats[2]는 방어력.
    int health = int.parse(stats[0]);
    int attack = int.parse(stats[1]);
    int defense = int.parse(stats[2]);

    character = Character(characterName, health, attack, defense);
    print('캐릭터 스탯을 성공적으로 불러왔습니다!');
    character?.showStatus();
  } catch (e) {
    print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
  }
}

// 몬스터들의 스택을 불러오는 함수.
void loadMonsterStats() {
  try {
    final file = File('file/monsters.txt');
    final contents = file.readAsStringSync();
    final lines = contents.split('\n');

    for (var line in lines) {
      //trim()은 문자열의 양쪽 공백을 제거함. continue는 빈 문자열일 경우 건너뛰기.
      if (line.trim().isEmpty) continue;

      final stats = line.split(',');
      if (stats.length != 3) throw FormatException('파일 형식을 확인해주세요.');

      String name = stats[0];
      int health = int.parse(stats[1]);
      int maxAttack = int.parse(stats[2]);

      monsters.add(Monster(name, health, maxAttack));
    }

    // 몬스터 리스트를 랜덤하게 섞기
    final getRandomMonster = Random();
    monsters.shuffle(getRandomMonster);

    // print('\n=== 몬스터 목록 ===');
    // for (var monster in monsters) {
    //   monster.showStatus();
    // }
  } catch (e) {
    print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
  }
}

void battle(Character player, Monster currentMonster) {
  while (true) {
    print('\n${player.name}의 턴');
    print('행동을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용): ');

    String? input = stdin.readLineSync();

    if (input == '1') {
      player.attackMonster(currentMonster);
      break;
    } else if (input == '2') {
      player.defend(currentMonster.attack);
      break;
    } else if (input == '3' && !usedItem) {
      print('아이템을 사용하여 공격력이 2배가 됩니다!');
      int originalAttack = player.attack;
      player.attack *= 2;
      player.attackMonster(currentMonster);
      player.attack = originalAttack;
      usedItem = true;
      break;
    } else if (input == '3' && usedItem) {
      print('아이템을 이미 사용하였습니다. 다시 선택하세요.');
    } else {
      print('1, 2, 3 중 하나를 선택해주세요.');
    }
  }

  // 30% 확률로 체력 증가
  final randomHealthPlus = Random();
  if (randomHealthPlus.nextDouble() < 0.3) {
    player.health += 10;
    print('보너스 체력을 얻었습니다! 현재 체력: ${player.health}');
  }

  player.showStatus();
  currentMonster.showStatus();

  if (currentMonster.health > 0) {
    print('\n${currentMonster.name}의 턴');
    currentMonster.attackCharacter(player);

    player.showStatus();
    currentMonster.showStatus();
  }

  // 3번째 턴마다 몬스터의 방어력 증가
  turnCount++;
  if (turnCount % 3 == 0) {
    currentMonster.defense += 2;
    print(
      '${currentMonster.name}의 방어력이 증가했습니다! 현재 방어력: ${currentMonster.defense}',
    );
  }
}

void saveGameResult(String characterName, int remainingHealth, bool isVictory) {
  String message =
      isVictory ? '결과를 저장하시겠습니까? (y/n):' : '\n패배했습니다. 결과를 저장하시겠습니까? (y/n):';
  print(message);
  //입력된 문자가 소문자로 저장됨.
  String? input = stdin.readLineSync()?.toLowerCase();

  while (true) {
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
      break;
    } else if (input == 'n') {
      print('게임 결과가 저장되지 않았습니다.');
      break;
    } else {
      print('y 또는 n을 입력해주세요.');
      input = stdin.readLineSync()?.toLowerCase();
    }
  }
}

void startGame() {
  if (character == null || monsters.isEmpty) return;

  print('\n새로운 몬스터가 나타났습니다!');
  Monster currentMonster = monsters[0];
  currentMonster.showStatus();

  while (character!.health > 0 && currentMonster.health > 0) {
    battle(character!, currentMonster);

    if (currentMonster.health <= 0) {
      print('\n${currentMonster.name}을(를) 물리쳤습니다!');
      monsters.removeAt(0);

      if (monsters.isNotEmpty) {
        while (true) {
          print('\n다른 몬스터와 싸우시겠습니까? (y/n):');
          String? input = stdin.readLineSync()?.toLowerCase();
          if (input == 'y') {
            print('\n새로운 몬스터가 나타났습니다!');
            currentMonster = monsters[0];
            currentMonster.showStatus();
            break;
          } else if (input == 'n') {
            saveGameResult(character!.name, character!.health, true);
            break;
          } else {
            print('y 또는 n을 입력해주세요.');
          }
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
    if (RegExp(r'^[a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]+$').hasMatch(characterName)) {
      break;
    } else {
      print('한글, 영문대소문자만 입력해주세요:');
    }
  }
  print('게임을 시작합니다!');
  loadCharacterStats(characterName);
  loadMonsterStats();
  startGame();
}
