all: html-xsl

include $(DOCBOOK_MAK_MAKEFILES_PATH)/docbook-render.mak

# Upload targets

upload: $(UPLOAD_DEPS)
	$(RSYNC) -a $(FILES_TO_UPLOAD) $(UPLOAD_PATH)

upload_all_in_one: all_in_one_html
	$(RSYNC) -a $(HTML_ONECHUNK_TARGET) $(UPLOAD_ONECHUNK_PATH)
