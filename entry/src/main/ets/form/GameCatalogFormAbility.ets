import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formProvider from '@ohos.app.form.formProvider';
import formBindingData from '@ohos.app.form.formBindingData';
import { Want } from '@kit.AbilityKit';

/**
 * 卡片数据接口
 */
interface FormData {
  title: string;
  icon: string;
}

/**
 * 游戏中心卡片服务
 */
export default class GameCatalogFormAbility extends FormExtensionAbility {
  onAddForm(_want: Want): formBindingData.FormBindingData {
    // 创建卡片时调用
    console.info('GameCatalogFormAbility onAddForm');

    const formData: FormData = {
      title: '游戏中心',
      icon: '🎮'
    };

    return formBindingData.createFormBindingData(formData);
  }

  onUpdateForm(formId: string): void {
    // 更新卡片时调用
    console.info('GameCatalogFormAbility onUpdateForm');

    const formData: FormData = {
      title: '游戏中心',
      icon: '🎮'
    };

    const formBindingDataObj = formBindingData.createFormBindingData(formData);
    formProvider.updateForm(formId, formBindingDataObj).catch((err: Error) => {
      console.error('Failed to update form:', err.message);
    });
  }

  onRemoveForm(_formId: string): void {
    // 删除卡片时调用
    console.info('GameCatalogFormAbility onRemoveForm');
  }

  onFormEvent(_formId: string, message: string): void {
    // 卡片事件处理
    console.info('GameCatalogFormAbility onFormEvent: ' + message);
  }
}
