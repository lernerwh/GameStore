import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { GameCatalog } from '../main/ets/model/GameInfo';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });

    it('gameCatalog_returns_enabled_games', 0, () => {
      const games = GameCatalog.getGames();
      expect(games.length > 0).assertEqual(true);
      for (const game of games) {
        expect(game.enabled).assertEqual(true);
      }
    });

    it('gameCatalog_can_find_snake_game', 0, () => {
      const snakeGame = GameCatalog.getGameById('snake');
      expect(!!snakeGame).assertEqual(true);
      expect(snakeGame?.page).assertEqual('pages/SnakeGame');
    });

    it('gameCatalog_returns_undefined_for_unknown_id', 0, () => {
      const unknown = GameCatalog.getGameById('unknown_game_id');
      expect(unknown === undefined).assertEqual(true);
    });
  });
}
