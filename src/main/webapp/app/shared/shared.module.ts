import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { DevopsdemoSharedLibsModule, DevopsdemoSharedCommonModule, JhiLoginModalComponent, HasAnyAuthorityDirective } from './';

@NgModule({
  imports: [DevopsdemoSharedLibsModule, DevopsdemoSharedCommonModule],
  declarations: [JhiLoginModalComponent, HasAnyAuthorityDirective],
  entryComponents: [JhiLoginModalComponent],
  exports: [DevopsdemoSharedCommonModule, JhiLoginModalComponent, HasAnyAuthorityDirective],
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class DevopsdemoSharedModule {
  static forRoot() {
    return {
      ngModule: DevopsdemoSharedModule
    };
  }
}
