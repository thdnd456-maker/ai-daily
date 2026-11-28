// 식단 근거 자료와 음식 정보
//
// - 요약은 원문을 대체하지 않습니다. 수치는 원문에서 널리 인용되는 값만 적었습니다.
// - 음식 영양 정보는 대략값입니다(제품·조리법마다 다름). 포장지 표시가 있으면 그 값을 따르세요.

import '../engines/nutrition_engine.dart';
import 'research.dart';

const nutritionReferences = <ResearchReference>[
  ResearchReference(
    id: 'morton_2018_protein',
    title: 'A systematic review, meta-analysis and meta-regression of the effect of protein supplementation on resistance training-induced gains in muscle mass and strength in healthy adults',
    authors: 'Morton RW, Murphy KT, McKellar SR, et al.',
    year: 2018,
    journal: 'British Journal of Sports Medicine',
    studyType: '메타분석 (49개 연구, 1,863명)',
    population: '근력운동을 하는 건강한 성인',
    keyFindings: '단백질을 늘리면 근육량·근력 증가가 커지지만, 하루 체중 1kg당 약 1.6g을 넘으면 추가 효과가 거의 없었습니다(95% 신뢰구간 상단 약 2.2g).',
    limitations: '대부분 단기 연구이고, 감량 중인 사람은 따로 분석하지 않았습니다.',
    appliedIn: '유지·증량 단계 단백질 1.6g/kg (경력자 증량은 1.8g/kg)',
  ),
  ResearchReference(
    id: 'issn_2017_protein',
    title: 'International Society of Sports Nutrition Position Stand: protein and exercise',
    authors: 'Jäger R, Kerksick CM, Campbell BI, et al.',
    year: 2017,
    journal: 'Journal of the International Society of Sports Nutrition',
    studyType: '학회 입장문 (문헌 종합)',
    population: '운동하는 사람',
    keyFindings: '운동하는 사람은 하루 1.4~2.0g/kg이 적절하고, 3~4시간 간격으로 끼니당 20~40g씩 나눠 먹는 것을 권합니다. 이 범위는 건강한 사람에게 안전합니다.',
    limitations: '신장 질환이 있는 사람은 해당하지 않습니다.',
    appliedIn: '단백질 범위, 끼니 나누기',
  ),
  ResearchReference(
    id: 'helms_2014_prep',
    title: 'Evidence-based recommendations for natural bodybuilding contest preparation: nutrition and supplementation',
    authors: 'Helms ER, Aragon AA, Fitschen PJ',
    year: 2014,
    journal: 'Journal of the International Society of Sports Nutrition',
    studyType: '문헌 고찰',
    population: '감량 중인 근력운동 선수',
    keyFindings: '주당 체중의 0.5~1%씩 천천히 빼면 근육을 더 잘 지킵니다. 감량 중 단백질은 제지방량 1kg당 2.3~3.1g, 지방은 열량의 15~30%를 권합니다.',
    limitations: '대회를 준비하는 마른 선수 기준이라 일반인에게는 다소 엄격합니다.',
    appliedIn: '감량 속도, 감량 중 단백질 2.0~2.2g/kg, 지방 비율',
  ),
  ResearchReference(
    id: 'iraki_2019_offseason',
    title: 'Nutrition Recommendations for Bodybuilders in the Off-Season: A Narrative Review',
    authors: 'Iraki J, Fitschen P, Espinar S, Helms E',
    year: 2019,
    journal: 'Sports (Basel)',
    studyType: '문헌 고찰',
    population: '증량기의 근력운동 선수',
    keyFindings: '증량은 주당 체중의 0.25~0.5% 정도로 천천히 해야 지방이 덜 붙습니다. 경력이 많을수록 더 천천히 늘리는 것을 권합니다.',
    limitations: '직접 비교한 실험이 적고 전문가 의견이 섞여 있습니다.',
    appliedIn: '증량 속도와 하루 추가 열량',
  ),
  ResearchReference(
    id: 'schoenfeld_2018_meal',
    title: 'How much protein can the body use in a single meal for muscle-building? Implications for daily protein distribution',
    authors: 'Schoenfeld BJ, Aragon AA',
    year: 2018,
    journal: 'Journal of the International Society of Sports Nutrition',
    studyType: '문헌 고찰',
    population: '근력운동을 하는 성인',
    keyFindings: '근육 성장을 최대로 하려면 끼니당 체중 1kg당 약 0.4g씩, 하루 4끼 이상에 나눠 먹는 방법을 제안합니다.',
    limitations: '한 끼에 많이 먹어도 흡수는 되므로, 끼니 수는 생활에 맞춰도 됩니다.',
    appliedIn: '끼니당 단백질 목표',
  ),
  ResearchReference(
    id: 'mifflin_1990_ree',
    title: 'A new predictive equation for resting energy expenditure in healthy individuals',
    authors: 'Mifflin MD, St Jeor ST, Hill LA, et al.',
    year: 1990,
    journal: 'American Journal of Clinical Nutrition',
    studyType: '측정 연구 (498명)',
    population: '건강한 성인 남녀',
    keyFindings: '키·몸무게·나이·성별로 쉬고 있을 때 쓰는 열량(기초대사량)을 추정하는 공식을 만들었습니다. 이후 여러 비교 연구에서 정확도가 좋은 편으로 평가받았습니다.',
    limitations: '개인 오차가 ±10% 정도 날 수 있습니다. 그래서 실제 체중 변화로 다시 맞춰야 합니다.',
    appliedIn: '기초대사량 계산',
  ),
  ResearchReference(
    id: 'hall_2011_energy',
    title: 'Quantification of the effect of energy imbalance on bodyweight',
    authors: 'Hall KD, Sacks G, Chandramohan D, et al.',
    year: 2011,
    journal: 'The Lancet',
    studyType: '수학 모델 연구',
    population: '성인',
    keyFindings: '"1kg = 7,700kcal" 같은 단순 계산은 시간이 지날수록 틀어집니다. 몸이 적응하기 때문에 실제 체중 변화를 보고 조정해야 합니다.',
    limitations: '모델 연구라 개인차를 다 반영하지는 못합니다.',
    appliedIn: '체중 추세로 칼로리 조정 (중급·전문가)',
  ),
  ResearchReference(
    id: 'acsm_2016_nutrition',
    title: 'Nutrition and Athletic Performance (Joint Position Statement)',
    authors: 'Thomas DT, Erdman KA, Burke LM',
    year: 2016,
    journal: 'Medicine & Science in Sports & Exercise',
    studyType: '학회 공동 입장문 (미국스포츠의학회 등)',
    population: '운동선수와 활동적인 사람',
    keyFindings: '탄수화물은 활동량에 맞춰 하루 3~10g/kg 범위에서 조절하고, 운동량이 많은 날 더 먹는 것을 권합니다.',
    limitations: '지구력 종목 자료가 많습니다.',
    appliedIn: '운동일/휴식일 탄수화물 나누기 (전문가)',
  ),
  ResearchReference(
    id: 'issn_2017_timing',
    title: 'International Society of Sports Nutrition position stand: nutrient timing',
    authors: 'Kerksick CM, Arent S, Schoenfeld BJ, et al.',
    year: 2017,
    journal: 'Journal of the International Society of Sports Nutrition',
    studyType: '학회 입장문',
    population: '운동하는 사람',
    keyFindings: '하루 총량이 가장 중요하고, 운동 전후 몇 시간 안에 단백질(20~40g)과 탄수화물을 먹으면 회복에 도움이 될 수 있습니다.',
    limitations: '하루 총량을 지키면 타이밍 효과는 작습니다.',
    appliedIn: '운동 전후 식사 (전문가)',
  ),
  ResearchReference(
    id: 'issn_2017_creatine',
    title: 'International Society of Sports Nutrition position stand: safety and efficacy of creatine supplementation in exercise, sport, and medicine',
    authors: 'Kreider RB, Kalman DS, Antonio J, et al.',
    year: 2017,
    journal: 'Journal of the International Society of Sports Nutrition',
    studyType: '학회 입장문',
    population: '운동하는 사람',
    keyFindings: '크레아틴은 근력·근육량 증가에 효과가 가장 확실한 보충제이며, 하루 3~5g이면 충분하고 건강한 사람에게 안전합니다.',
    limitations: '신장 질환이 있으면 의사와 상의해야 합니다.',
    appliedIn: '보충제 안내 (전문가)',
  ),
  ResearchReference(
    id: 'byrne_2018_matador',
    title: 'Intermittent energy restriction improves weight loss efficiency in obese men: the MATADOR study',
    authors: 'Byrne NM, Sainsbury A, King NA, et al.',
    year: 2018,
    journal: 'International Journal of Obesity',
    studyType: '무작위 대조 실험 (51명)',
    population: '비만 남성',
    keyFindings: '2주 감량 + 2주 유지를 반복한 그룹이 계속 감량한 그룹보다 지방을 더 많이 빼고 요요가 적었습니다.',
    limitations: '비만 남성만 대상으로 했고 인원이 적습니다.',
    appliedIn: '긴 감량 중 "다이어트 휴식" 안내 (전문가)',
  ),
];

class FoodItem {
  final String name;
  final String serving;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int kcal;
  final String emoji;
  const FoodItem(this.name, this.serving, this.proteinG, this.carbsG, this.fatG, this.kcal, [this.emoji = '🍽️']);
}

/// 자주 먹는 음식 (대략값)
const proteinFoods = <FoodItem>[
  FoodItem('닭가슴살 (익힌 것)', '100g', 31, 0, 4, 165, '🍗'),
  FoodItem('달걀', '1개', 6, 0, 5, 75, '🥚'),
  FoodItem('소고기 우둔·홍두깨 (익힌 것)', '100g', 29, 0, 6, 180, '🥩'),
  FoodItem('돼지 안심 (익힌 것)', '100g', 27, 0, 4, 150, '🥩'),
  FoodItem('고등어구이', '1토막 100g', 23, 0, 17, 250, '🐟'),
  FoodItem('참치캔 (기름 뺀 것)', '100g', 24, 0, 2, 130, '🐟'),
  FoodItem('두부', '반 모 150g', 13, 3, 7, 120, '🧈'),
  FoodItem('그릭요거트 (무가당)', '100g', 9, 4, 3, 75, '🥣'),
  FoodItem('우유', '200ml', 6, 10, 7, 130, '🥛'),
  FoodItem('단백질 보충제', '1스쿱 30g', 24, 3, 2, 120, '🥤'),
];

const carbFoods = <FoodItem>[
  FoodItem('쌀밥', '1공기 210g', 6, 65, 1, 300, '🍚'),
  FoodItem('고구마', '중 1개 150g', 2, 30, 0, 130, '🍠'),
  FoodItem('바나나', '1개', 1, 27, 0, 105, '🍌'),
  FoodItem('오트밀', '40g', 5, 27, 3, 150, '🥣'),
  FoodItem('통밀빵', '1장', 4, 15, 1, 80, '🍞'),
];

const fatFoods = <FoodItem>[
  FoodItem('견과류', '한 줌 25g', 5, 5, 13, 150, '🥜'),
  FoodItem('올리브유', '1큰술', 0, 0, 14, 120, '🫒'),
  FoodItem('아보카도', '반 개', 1, 6, 15, 160, '🥑'),
];

/// 한식·외식 1인분 (대략값, 식당마다 차이 큼)
const dishFoods = <FoodItem>[
  FoodItem('김치찌개', '1인분', 15, 10, 17, 260, '🍲'),
  FoodItem('된장찌개', '1인분', 10, 10, 7, 150, '🍲'),
  FoodItem('비빔밥', '1그릇', 20, 90, 17, 600, '🍚'),
  FoodItem('김밥', '1줄', 13, 70, 12, 450, '🍙'),
  FoodItem('라면', '1개', 10, 78, 16, 500, '🍜'),
  FoodItem('짜장면', '1그릇', 20, 120, 25, 800, '🍜'),
  FoodItem('제육볶음', '1인분', 28, 15, 30, 450, '🥘'),
  FoodItem('닭갈비', '1인분', 35, 25, 20, 450, '🥘'),
  FoodItem('삼겹살 구이', '1인분 (생 200g)', 34, 0, 57, 660, '🥓'),
  FoodItem('후라이드 치킨', '3조각', 36, 24, 38, 600, '🍗'),
  FoodItem('돈까스', '1인분', 30, 60, 42, 750, '🍛'),
  FoodItem('순대국', '1그릇', 30, 45, 25, 550, '🍲'),
  FoodItem('떡볶이', '1인분', 11, 95, 6, 480, '🌶️'),
  FoodItem('편의점 도시락', '1개', 25, 100, 22, 700, '🍱'),
  FoodItem('샐러드 (드레싱 포함)', '1그릇', 4, 15, 14, 200, '🥗'),
  FoodItem('나물·김치 반찬', '1접시', 2, 6, 1, 40, '🥬'),
  FoodItem('채소 (생·데친 것)', '1접시 100g', 2, 7, 0, 35, '🥦'),
];

/// 간식·음료 (대략값)
const snackFoods = <FoodItem>[
  FoodItem('사과', '1개', 0, 25, 0, 95, '🍎'),
  FoodItem('프로틴바', '1개', 20, 20, 7, 200, '🍫'),
  FoodItem('단팥빵', '1개', 7, 50, 5, 280, '🥐'),
  FoodItem('아메리카노', '1잔', 0, 2, 0, 10, '☕'),
  FoodItem('카페라떼', '1잔 (톨)', 9, 14, 9, 180, '☕'),
  FoodItem('맥주', '500ml', 2, 17, 0, 210, '🍺'),
  FoodItem('소주', '1병', 0, 0, 0, 400, '🍶'),
];

/// 기록 화면의 음식 고르기 목록
const foodGroups = <(String, List<FoodItem>)>[('단백질', proteinFoods), ('밥·탄수화물', carbFoods), ('한식·외식', dishFoods), ('간식·음료', snackFoods), ('지방', fatFoods)];

/// 입문 단계 습관 (실천하기 쉬운 순서)
const beginnerHabits = <String>[
  '매끼 단백질 식품(고기·생선·달걀·두부·요거트)을 먼저 챙기기',
  '매끼 채소를 주먹 1~2개만큼 곁들이기',
  '단 음료·과자·술은 횟수부터 줄이기 (주 몇 번인지 세어 보기)',
  '물은 자주 마시기 (식사 전 한 컵)',
  '천천히 먹고, 배가 80%쯤 찼을 때 멈추기',
  '주 1~2번 아침 공복 체중을 「기록」 탭에 적기',
];

/// 끼니별 그림과 칼로리 배분 (아침 25% · 점심 35% · 저녁 30% · 간식 10%, 앱 기본값)
const mealMeta = <String, (String, String, double)>{
  'breakfast': ('아침', '🍳', 0.25),
  'lunch': ('점심', '🍱', 0.35),
  'dinner': ('저녁', '🍲', 0.30),
  'snack': ('간식', '🍎', 0.10),
};

/// 끼니별 추천 메뉴 (한식, 짧게). 목표에 따라 밥 양이 달라집니다.
List<String> mealSuggestion(String slot, DietPhase phase) {
  final rice = switch (phase) {
    DietPhase.cut => ('2/3공기', '반 공기'),
    DietPhase.maintain => ('1공기', '2/3공기'),
    DietPhase.gain => ('1.5공기', '1공기'),
  };
  return switch (slot) {
    'breakfast' => ['🥣 그릭요거트 200g', '🌾 오트밀 40g', phase == DietPhase.cut ? '🍎 사과 반 개' : '🍌 바나나 1개'],
    'lunch' => ['🍚 밥 ${rice.$1}', '🍗 닭가슴살·살코기 150g', '🥬 나물·김치'],
    'dinner' => ['🍚 밥 ${rice.$2}', '🐟 생선 1토막 또는 두부 반 모', '🥗 채소 듬뿍'],
    _ => [phase == DietPhase.gain ? '🥤 셰이크 1스쿱 + 🍠 고구마' : '🥛 우유 200ml 또는 🥤 셰이크', if (phase == DietPhase.gain) '🥜 견과류 한 줌'],
  };
}

/// 끼니 추천: (음식, 몇 배). 화면에서 누르면 바로 기록됩니다.
List<(FoodItem, double)> mealSuggestionFoods(String slot, DietPhase phase) {
  FoodItem f(String name) => foodGroups.expand((g) => g.$2).firstWhere((x) => x.name == name);
  final (lunchRice, dinnerRice) = switch (phase) {
    DietPhase.cut => (0.67, 0.5),
    DietPhase.maintain => (1.0, 0.67),
    DietPhase.gain => (1.5, 1.0),
  };
  return switch (slot) {
    'breakfast' => [(f('그릭요거트 (무가당)'), 2.0), (f('오트밀'), 1.0), phase == DietPhase.cut ? (f('사과'), 0.5) : (f('바나나'), 1.0)],
    'lunch' => [(f('쌀밥'), lunchRice), (f('닭가슴살 (익힌 것)'), 1.5), (f('나물·김치 반찬'), 1.0)],
    'dinner' => [(f('쌀밥'), dinnerRice), (f('두부'), 1.0), (f('채소 (생·데친 것)'), 1.0)],
    _ => phase == DietPhase.gain ? [(f('단백질 보충제'), 1.0), (f('고구마'), 1.0), (f('견과류'), 1.0)] : [(f('우유'), 1.0), (f('단백질 보충제'), 1.0)],
  };
}

/// 양 표시: 「100g」×2 → 「200g」, 그 밖에는 「1공기 210g × 1.5」
String servingLabel(FoodItem f, double times) {
  if (times == 1) return f.serving;
  final m = RegExp(r'^(\d+)(g|ml)$').firstMatch(f.serving);
  if (m != null) return '${(int.parse(m[1]!) * times).round()}${m[2]}';
  final t = times == times.roundToDouble() ? times.toInt().toString() : (times == 0.67 ? '2/3' : '$times');
  return '${f.serving} × $t';
}

/// 비슷한 칼로리로 바꿀 만한 음식 (음식, 배수). 단백질이 많은 순.
List<(FoodItem, double)> swapCandidates({required String name, required double kcal, int limit = 8}) {
  if (kcal <= 0) return const [];
  final out = <(FoodItem, double)>[];
  for (final f in foodGroups.expand((g) => g.$2)) {
    if (f.name == name || f.kcal <= 0) continue;
    final t = const [0.5, 1.0, 1.5, 2.0, 3.0].reduce((a, b) => ((f.kcal * a) - kcal).abs() <= ((f.kcal * b) - kcal).abs() ? a : b);
    if (((f.kcal * t) - kcal).abs() > kcal * 0.35) continue;
    out.add((f, t));
  }
  out.sort((a, b) => (b.$1.proteinG * b.$2).compareTo(a.$1.proteinG * a.$2));
  return out.take(limit).toList();
}

/// 전문가 단계 추가 안내
const expertTips = <String>[
  '운동 1~3시간 전: 단백질 20~40g + 소화 잘되는 탄수화물 (예: 밥 반 공기 + 닭가슴살)',
  '운동 후 2시간 안: 단백질 20~40g + 탄수화물 (ISSN 2017 타이밍 입장문)',
  '자기 전: 그릭요거트·우유 같은 단백질 식품을 넣으면 하루 목표를 채우기 쉬움',
  '크레아틴 하루 3~5g은 근거가 가장 확실한 보충제 (시간 상관없이 매일)',
  '감량이 12주 넘게 길어지면 1~2주는 유지 칼로리로 먹는 "다이어트 휴식"을 고려 (MATADOR 2018)',
  '체중은 매일 같은 조건(아침·화장실 후)으로 재고, 하루 값이 아니라 2주 추세로 판단',
];

/// 끼니 하나를 만들 때의 예시 양: 단백질 g → 닭가슴살 g, 탄수화물 g → 밥 공기
String mealExample(int proteinG, int carbsG) {
  final chicken = (proteinG / 31 * 100 / 10).round() * 10;
  final eggs = (proteinG / 6).round();
  final bowls = carbsG / 65;
  final b = bowls < 0.2
      ? '밥 조금'
      : bowls < 0.4
      ? '밥 1/3공기'
      : bowls < 0.6
      ? '밥 반 공기'
      : bowls < 0.85
      ? '밥 2/3공기'
      : bowls < 1.2
      ? '밥 1공기'
      : '밥 ${bowls.toStringAsFixed(1)}공기';
  return '닭가슴살 약 ${chicken}g (또는 달걀 약 $eggs개) + $b + 채소';
}
