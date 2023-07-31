<template>
  <div class="mt-4">
    <tr>
      <td cols="12">
        Click on the sheet =>
        <v-chip
          class="mr-2"
          :class="selectedSheet === sheet ? 'active' : ''"
          v-for="sheet in spreadsheet.SheetNames"
          :key="sheet"
          @click="selectSheet(sheet)"
        >
          {{ sheet }}
        </v-chip>
      </td>
    </tr>
    <div v-for="sheet in spreadsheet.SheetNames" :key="sheet" class="mt-2">
      <div v-if="selectedSheet === sheet">
        <table border="1">
          <thead>
            <tr class="flex-nowrap bg-white">
              <th v-for="header in headers" :key="header">
                {{ header }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="i in maxRows" :index="i">
              <td v-for="header in headers" :key="header">
                {{
                  formattedData[header][i - 1]
                    ? formattedData[header][i - 1]
                    : "&nbsp;"
                }}
              </td>
            </tr>
          </tbody>
        </table>
        <v-btn @click="finishMapping">Finished Mapping</v-btn>
      </div>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive } from "vue";

const props = defineProps({
  spreadsheet: {
    type: Object,
    required: true,
  },
});
const emit = defineEmits<{
  (e: "data-mapped", data: any): void;
}>();

const selectedSheet = ref("");
const fieldsToMap: any[] = [
  { label: "Date", field: "date", assigned_field: ["date"] },
  { label: "Insured", field: "insured", assigned_field: ["insured"] },
  { label: "Insurer A", field: "insurer_a", assigned_field: ["insurer_a"] },
  {
    label: "Insurer A NAIC",
    field: "insurer_a_naic",
    assigned_field: ["insurer_a_naic"],
  },
  { label: "Insurer B", field: "insurer_b", assigned_field: ["insurer_b"] },
  {
    label: "Insurer B NAIC",
    field: "insurer_b_naic",
    assigned_field: ["insurer_b_naic"],
  },
  { label: "Insurer C", field: "insurer_c", assigned_field: ["insurer_c"] },
  {
    label: "Insurer C NAIC",
    field: "insurer_c_naic",
    assigned_field: ["insurer_c_naic"],
  },
  { label: "Insurer D", field: "insurer_d", assigned_field: ["insurer_d"] },
  {
    label: "Insurer D NAIC",
    field: "insurer_d_naic",
    assigned_field: ["insurer_d_naic"],
  },
  { label: "Insurer E", field: "insurer_e", assigned_field: ["insurer_e"] },
  {
    label: "Insurer E NAIC",
    field: "insurer_e_naic",
    assigned_field: ["insurer_e_naic"],
  },
  { label: "Insurer F", field: "insurer_f", assigned_field: ["insurer_f"] },
  {
    label: "Insurer F NAIC",
    field: "insurer_f_naic",
    assigned_field: ["insurer_f_naic"],
  },
  {
    label: "Commercial Liability - Instr Letter",
    field: "cl_instr_letter",
    assigned_field: ["cl_instr_letter"],
  },
  {
    label: "Commercial Liability - Claims Made",
    field: "claims_made",
    assigned_field: ["claims_made"],
  },
  {
    label: "Commercial Liability - Occur",
    field: "occur",
    assigned_field: ["occur"],
  },
  {
    label: "Commercial Liability - Additional Insured",
    field: "cl_addl_insd",
    assigned_field: ["cl_addl_insd"],
  },
  {
    label: "Commercial Liability - Subrogation Waived",
    field: "cl_subr_wvd",
    assigned_field: ["cl_subr_wvd"],
  },
  {
    label: "Commercial Liability - Policy Number",
    field: "cl_policy_number",
    assigned_field: ["cl_policy_number"],
  },
  {
    label: "Commercial Liability - Policy Effective Date",
    field: "cl_policy_eff",
    assigned_field: ["cl_policy_eff"],
  },
  {
    label: "Commercial Liability - Policy Expiration Date",
    field: "cl_policy_exp",
    assigned_field: ["cl_policy_exp"],
  },
  {
    label: "Commercial Liability - Each Occurrence",
    field: "cl_each_occurrence",
    assigned_field: ["cl_each_occurrence"],
  },
  {
    label: "Commercial Liability - Damage to Rented",
    field: "cl_damaged_to_rented",
    assigned_field: ["cl_damaged_to_rented"],
  },
  {
    label: "Commercial Liability - Medical Expenses",
    field: "cl_med_exp",
    assigned_field: ["cl_med_exp"],
  },
  {
    label: "Commercial Liability - Personal Adv Injury",
    field: "cl_personal_adv_injury",
    assigned_field: ["cl_personal_adv_injury"],
  },
  {
    label: "Commercial Liability - General Aggregate",
    field: "cl_general_aggregate",
    assigned_field: ["cl_general_aggregate"],
  },
  {
    label: "Commercial Liability - Products Completion",
    field: "cl_products_comp",
    assigned_field: ["cl_products_comp"],
  },
  {
    label: "Commercial Liability - Agg Limit - Per Policy ",
    field: "cl_agg_limit_per_policy",
    assigned_field: ["cl_agg_limit_per_policy"],
  },
  {
    label: "Commercial Liability - Agg Limit - Per Project",
    field: "cl_agg_limit_per_project",
    assigned_field: ["cl_agg_limit_per_project"],
  },
  {
    label: "Commercial Liability - Agg Limit - Per Location",
    field: "cl_agg_limit_per_location",
    assigned_field: ["cl_agg_limit_per_location"],
  },
  {
    label: "Excess - Instr Letter",
    field: "instr_ltr_2",
    assigned_field: ["instr_ltr_2"],
  },
  {
    label: "Umbrella Liability",
    field: "umbrella_liab",
    assigned_field: ["umbrella_liab"],
  },
  {
    label: "Excess/Umbrella - Occur",
    field: "umbrella_occur",
    assigned_field: ["umbrella_occur"],
  },
  {
    label: "Excess Liability",
    field: "excess_liab",
    assigned_field: ["excess_liab"],
  },
  {
    label: "Excess/Umbrella - Claims Made",
    field: "excess_claims_made",
    assigned_field: ["excess_claims_made"],
  },
  {
    label: "Excess Policy Number",
    field: "excess_policy_number",
    assigned_field: ["excess_policy_number"],
  },
  {
    label: "Excess Policy Effective Date",
    field: "excess_policy_eff",
    assigned_field: ["excess_policy_eff"],
  },
  {
    label: "Excess Policy Expiration Date",
    field: "excess_policy_exp",
    assigned_field: ["excess_policy_exp"],
  },
  {
    label: "Excess Each Occurrence",
    field: "excess_each_occurrence",
    assigned_field: ["excess_each_occurrence"],
  },
  {
    label: "Excess Aggregate",
    field: "excess_aggregate",
    assigned_field: ["excess_aggregate"],
  },
  { label: "Location", field: "location", assigned_field: ["location"] },
  {
    label: "Certificate Holder",
    field: "certificate_holder",
    assigned_field: ["certificate_holder"],
  },
];
const headers: any = ref([]);
const columnToHeader: any = reactive({});
const formattedData: any = ref([]);
let maxRows = ref<number>(0);
const sheetData = ref<any>(null);

const selectSheet = (sheet: string) => {
  selectedSheet.value = sheet;
  sheetData.value = null;
  sheetData.value = props.spreadsheet.Sheets[sheet];
  headers.value = [];
  formattedData.value = [];
  maxRows.value = 0;
  const pattern = RegExp(/([A-Z]+)(\d+)/);
  if (sheetData.value) {
    Object.keys(sheetData.value).forEach((item: string) => {
      if (!["!autofilter", "!margins", "!ref"].includes(item)) {
        const parts = item.match(pattern);
        const o = sheetData?.value[item];
        if (parts !== null && parts.length > 2) {
          // This is a header
          if (parts[2] === "1") {
            headers.value.push(o.w);
            columnToHeader[parts[1]] = o.w;
            formattedData.value[o.w] = [];
          } else {
            // This is data for the header
            const header = columnToHeader[parts[1]];
            formattedData.value[header].push(o.w);
          }
        }
      }
    });
    headers.value.forEach((header: string) => {
      if (formattedData.value[header].length > maxRows.value) {
        maxRows.value = formattedData.value[header].length;
      }
    });
  }
};
const finishMapping = () => {
  const mappedData: any = {};
  fieldsToMap.forEach((o: any) => {
    mappedData[o.field] = [];
    for (let i = 0; i < maxRows.value; i++) {
      const c: any[] = [];
      o.assigned_field.forEach((s: string) => {
        c.push(formattedData.value[s][i] ? formattedData.value[s][i] : "");
      });
      mappedData[o.field].push(c.join(" "));
    }
  });
  emit("data-mapped", mappedData);
};
</script>
<style scoped>
.active {
  background-color: #ffff00;
}
select {
  background-color: #bbbbbb;
  max-width: 75px;
}
table {
  display: block;
  max-width: 75vw;
  max-height: 70vh;
  overflow: auto;
}
</style>
