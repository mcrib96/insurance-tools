<template>
  <div class="ma-10">
    <h2>Acord Form 25 - Certificate of Liability Insurance</h2>
    <a href="/insurance/assets/Acord 25 Template.xlsx"
      >Download the Excel template</a
    ><br />
    <a href="/insurance/assets/Test 25.xlsx">Download a sample file</a><br />
    <br />
    <i>
      Note: To add multiple lines in a single cell, press Alt+Enter to move to
      the next line within the cell.
    </i>
    <file-upload @spreadsheet-loaded="spreadSheetLoaded" />
    <v-divider />
    <field-mapping-25
      :spreadsheet="spreadsheet"
      v-if="loaded && !mapped"
      @data-mapped="dataMap"
    />
    <v-btn @click="fillOutForm">Fill out Acord 25</v-btn>
    <div v-if="loading">
      <v-progress-circular class="mr-2" indeterminate size="20" />
      Loading ...
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onBeforeUnmount } from "vue";
import FileUpload from "../components/FileUpload.vue";
import FieldMapping25 from "../components/FieldMapping25.vue";

const loading = ref<boolean>(false);
const loaded = ref<boolean>(false);
const mapped = ref<boolean>(false);
const spreadsheet = ref<any>(null);
const mappedData = ref<any>(null);

const spreadSheetLoaded = (ss: any) => {
  loaded.value = true;
  spreadsheet.value = ss;
};
const dataMap = (data: any) => {
  mapped.value = true;
  mappedData.value = data;
  console.log("dataMap", data);
};
const buildObject = (index: number) => {
  const o: any = {};
  Object.keys(mappedData.value).forEach((key: string) => {
    o[key] = mappedData.value[key][index];
  });
  return o;
};
const fillOutForm = () => {
  loading.value = true;
  const body: any = { items: [] };
  const numElements = mappedData.value["location"].length;
  for (let i = 0; i < numElements; i++) {
    body.items.push(buildObject(i));
  }
  fetch("http://jennifer.obregon.life/cgi-bin/fill-25.pl", {
    method: "POST",
    body: JSON.stringify(body),
  })
    .then((res: any) => res.blob())
    .then((blob: any) => {
      var a = document.createElement("a");
      a.href = window.URL.createObjectURL(blob);
      a.download = "merged_acord_25.zip";
      a.click();
    })
    .catch((error: any) => {
      console.error("Errors posting", error);
    })
    .finally(() => {
      loading.value = false;
    });
};
onBeforeUnmount(() => {});
</script>
