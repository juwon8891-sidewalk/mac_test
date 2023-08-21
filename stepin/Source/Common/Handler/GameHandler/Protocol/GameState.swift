import Foundation

enum GameState {
    //아무 상태도 아닐때
    case none
    //모델 로드 완료 되었을때
    case loadingComplete
    //오토 레디가 시작되어, 카운트다운 중
    case startCountDown
    //게임 진행중
    case progress
    //게임 완료
    case completeGame
    //녹화 및 데이터 저장 완료 -> 화면 result창으로 넘어가야 하는 시점
    case finish
}
