<template>
  <div class="ma-10">
    <h2>Acord Forms</h2>
    <file-upload @spreadsheet-loaded="spreadSheetLoaded" />
    <v-divider />
    <field-mapping
      :spreadsheet="spreadsheet"
      v-if="loaded && !mapped"
      @data-mapped="dataMap"
    />
    <v-btn @click="fillOutForm">Fill out Acord 140</v-btn>
    <div v-if="loading">
      <v-progress-circular class="mr-2" indeterminate size="20" />
      Loading ...
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onBeforeUnmount } from "vue";
import FileUpload from "../components/FileUpload.vue";
import FieldMapping from "../components/FieldMapping.vue";

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
  if (o["building_value_soi"] === "") {
    o["building_value_soi"] = "Building Value";
  }
  if (o["rental_income_soi"] === "") {
    o["rental_income_soi"] = "Rental Income";
  }
  return o;
};
const fillOutForm = () => {
  loading.value = true;
  const body: any = { items: [] };
  const numElements = mappedData.value["street_address"].length;
  for (let i = 0; i < numElements; i++) {
    body.items.push(buildObject(i));
  }
  fetch("http://jennifer.obregon.life/cgi-bin/fill-140.pl", {
    method: "POST",
    body: JSON.stringify(body),
  })
    .then((res: any) => res.blob())
    .then((blob: any) => {
      var a = document.createElement("a");
      a.href = window.URL.createObjectURL(blob);
      a.download = "merged_acord_140.pdf";
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
