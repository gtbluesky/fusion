/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import FusionPlugin from './src/main/ets/components/plugin/FusionPlugin';
import Fusion from './src/main/ets/components/plugin/Fusion';
import FusionNavigator, { FusionRouteDelegate,
  FusionRouteType } from './src/main/ets/components/plugin/navigator/FusionNavigator';
import FusionEventManager, {
  FusionEventCallback,
  FusionEventType
} from './src/main/ets/components/plugin/event/FusionEvent';
import FusionMessengerHandler from './src/main/ets/components/plugin/handler/FusionMessengerHandler';
import FusionEntry from './src/main/ets/components/plugin/container/FusionEntry';
import buildFusionParams from './src/main/ets/components/plugin/container/FusionExt';
import FusionPage from './src/main/ets/components/plugin/container/FusionPage';
import FusionConstant from './src/main/ets/components/plugin/constant/FusionConstant';
import FusionComponent from './src/main/ets/components/plugin/container/FusionComponent';

export {
  Fusion,
  FusionConstant,
  FusionComponent,
  FusionEntry,
  FusionPage,
  buildFusionParams,
  FusionRouteDelegate,
  FusionRouteType,
  FusionMessengerHandler,
  FusionNavigator,
  FusionEventManager,
  FusionEventCallback,
  FusionEventType,
}

export default FusionPlugin;
