## 준비
2025.03.19
- 깃헙에 파일생성
- README 작성

---

## 필수기능
1. 파일로부터 데이터 읽어오기 기능 추가(txt파일 읽기) - csv파일로 저장하니 "가 생겨서 에러가 남.
2. 사용자로부터 캐릭터 이름받기 기능 - 정규표현식 사용해 한글/영어대소문자만 가능하도록 설정
3. 게임 종료 후 결과를 파일에 저장하는 기능 - writeAsStringSync()사용

#### 참고
1. 몬스터 처치 시, 새로운 몬스터 출현 여부 묻기
2. 모든 몬스터 처치 시, 결과 저장 여부 묻기
3. 방어시 방어력만큼 공격 방어.

---

## 도전기능
1. 캐릭터의 체력증가 기능 추가.(30%의 확률로 10씩 추가. 처음 시작할 때는 제외.)
2. 전투 시 캐릭터의 아이템 사용 기능 추가
3. 몬스터의 방어력 증가 기능 추가.

#### 참고
1. 3을 눌렀을 때, 아이템을 사용했다면, 사용했다는 문구가 나오면서 1, 2번 다시 선택하도록 유도.
2. 주석 추가.
3. 다른 번호 눌렀을 때, 1,2,3중에 1개 선택하라고 안내
4. 정규식 표현 중, 한글초성 입력시에도 진행가능하도록 변경
5. 게임결과 저장시, 다른몬스터와 싸움 질문시, y/n 를 제외한 문자 작성 시 다시 선택 유도.
6. 현재 전체 총 턴수와 몬스터의 턴수를 나눠서 구분함. 전체턴수는 전역변수, 몬스터 턴수는 클래스의 멤버로 정의. > 몬스터의 턴수가 3번째 턴이 될 때마다 방어력 2씩 증가