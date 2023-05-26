<template>
  <div class="ma-10">
    Upload a file
    <v-file-input label="Upload a spreadsheet" v-model="file"></v-file-input>
    <v-btn @click="upload" v-if="!loading">Upload</v-btn>
    <div v-if="loading">
      <v-progress-circular indeterminate size="20" class="mr-2" /> Processing
      ...
    </div>
  </div>
</template>
<script setup lang="ts">
import { read } from "xlsx";
import { ref } from "vue";
const emit = defineEmits(["spreadsheet-loaded"]);
const file = ref<any>(null);
const data = ref<any>(null);
const loading = ref<boolean>(false);

const processData = (d: any) => {
  data.value = d.target.result;
  const spreadsheet = read(data.value, { type: "buffer" });
  loading.value = false;
  emit("spreadsheet-loaded", spreadsheet);
};
const upload = () => {
  loading.value = true;
  const reader = new FileReader();
  reader.onload = (e: any) => {
    processData(e);
  };
  try {
    if (file.value && file.value.length > 0) {
      reader.readAsArrayBuffer(file.value[0]);
    }
  } catch (e) {
    console.error("upload", e);
  }
};
</script>
<style scoped>
.active {
  font-weight: bold;
  border: 1px solid #000000;
}
</style>
