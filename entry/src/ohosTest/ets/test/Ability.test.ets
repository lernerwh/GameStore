import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { GameCatalog } from '../../../main/ets/model/GameInfo';

export default function abilityTest() {
  describe('ActsAbilityTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('gameCatalog_has_catalog_items', 0, () => {
      const games = GameCatalog.getGames();
      expect(games.length > 0).assertEqual(true);
    })

    it('gameCatalog_contains_jumpjump', 0, () => {
      const jumpJump = GameCatalog.getGameById('jumpjump');
      expect(!!jumpJump).assertEqual(true);
      expect(jumpJump?.page).assertEqual('pages/JumpJumpGame');
    })
  })
}
