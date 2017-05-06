LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

$(call import-add-path,$(LOCAL_PATH)/../../cocos2d)
$(call import-add-path,$(LOCAL_PATH)/../../cocos2d/external)
$(call import-add-path,$(LOCAL_PATH)/../../cocos2d/cocos)

LOCAL_MODULE := cocos2dcpp_shared

LOCAL_MODULE_FILENAME := libcocos2dcpp

# 閬嶅巻鐩綍鍙婂瓙鐩綍鐨勫嚱鏁�  
define walk  
    $(wildcard $(1)) $(foreach e, $(wildcard $(1)/*), $(call walk, $(e)))  
endef  
  
# 閬嶅巻Classes鐩綍  
ALLFILES = $(call walk, $(LOCAL_PATH)/../../Classes)  
                     
FILE_LIST := hellocpp/main.cpp  
# 浠庢墍鏈夋枃浠朵腑鎻愬彇鍑烘墍鏈�.cpp鏂囦欢  
FILE_LIST += $(filter %.c, $(ALLFILES)) 
FILE_LIST += $(filter %.cpp, $(ALLFILES))   
  
LOCAL_SRC_FILES := $(FILE_LIST:$(LOCAL_PATH)/%=%)


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes \
					$(LOCAL_PATH)/../../Classes/AdmobHelper \
					
LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static

LOCAL_WHOLE_STATIC_LIBRARIES += cocosbuilder_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocostudio_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_network_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static


include $(BUILD_SHARED_LIBRARY)

$(call import-module,.)
$(call import-module,audio/android)

# $(call import-module,Box2D)
$(call import-module,editor-support/cocosbuilder)
#$(call import-module,editor-support/spine)
$(call import-module,editor-support/cocostudio)
$(call import-module,network)
$(call import-module,extensions)
LOCAL_CFLAGS += -DCOCOS2D_DEBUG=1


APP_STL := gnustl_static
APP_ABI := armeabi
USE_ARM_MODE := 1

