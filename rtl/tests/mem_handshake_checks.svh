  reg hs_i_pending = 1'b0, hs_d_pending = 1'b0;
  reg [3:0] hs_i_id, hs_d_id;
  reg hs_i_blocked = 1'b0, hs_d_blocked = 1'b0;
  reg hs_ir_blocked = 1'b0, hs_dr_blocked = 1'b0;
  reg [35:0] hs_i_offer;
  reg [36:0] hs_i_reply;
  reg [68:0] hs_d_reply;
  reg [76:0] hs_d_offer;
  integer hs_i_requests = 0, hs_i_responses = 0;
  integer hs_d_requests = 0, hs_d_responses = 0;
  integer hs_killed = 0;
  integer hs_i_overlap = 0, hs_held_killed = 0;
  string hs_wave;

  initial begin
    if ($value$plusargs("handshake_wave=%s", hs_wave)) begin
      $dumpfile(hs_wave);
      $dumpvars(0, testbench);
    end
  end

  always @(posedge clk) begin
    if (top.sync_rst) begin
      hs_i_pending <= 1'b0;
      hs_d_pending <= 1'b0;
      hs_i_blocked <= 1'b0;
      hs_d_blocked <= 1'b0;
      hs_ir_blocked <= 1'b0;
      hs_dr_blocked <= 1'b0;
    end else begin
      if (hs_i_blocked && (!top.u_core.core_instrom_ren ||
          {top.u_core.if_req_id, top.u_core.core_instrom_addr} != hs_i_offer))
        $fatal(1, "Instruction request changed under backpressure");
      if (hs_d_blocked && (!top.u_core.data_req_valid ||
          {top.u_core.data_req_id, top.u_core.core_dataram_addr, top.u_core.core_dataram_wen,
           top.u_core.core_dataram_wdata, top.u_core.core_dataram_alucex} != hs_d_offer))
        $fatal(1, "Data request changed under backpressure");
      if (hs_ir_blocked && (!top.u_core.if_rsp_valid ||
          {top.u_core.if_rsp_error, top.u_core.if_rsp_id, top.u_core.instrom_core_data} != hs_i_reply))
        $fatal(1, "Instruction response changed under backpressure");
      if (hs_dr_blocked && (!top.u_core.data_rsp_valid ||
          {top.u_core.data_rsp_fault_addr, top.u_core.data_rsp_error, top.u_core.data_rsp_id, top.u_core.dataram_core_rdata} != hs_d_reply))
        $fatal(1, "Data response changed under backpressure");
      hs_i_blocked <= top.u_core.core_instrom_ren && !top.u_core.if_req_ready;
      hs_d_blocked <= top.u_core.data_req_valid && !top.u_core.data_req_ready;
      hs_ir_blocked <= top.u_core.if_rsp_valid && !top.u_core.if_rsp_ready;
      hs_dr_blocked <= top.u_core.data_rsp_valid && !top.u_core.data_rsp_ready;
      hs_i_offer <= {top.u_core.if_req_id, top.u_core.core_instrom_addr};
      hs_d_offer <= {top.u_core.data_req_id, top.u_core.core_dataram_addr, top.u_core.core_dataram_wen,
                     top.u_core.core_dataram_wdata, top.u_core.core_dataram_alucex};
      hs_i_reply <= {top.u_core.if_rsp_error, top.u_core.if_rsp_id, top.u_core.instrom_core_data};
      hs_d_reply <= {top.u_core.data_rsp_fault_addr, top.u_core.data_rsp_error, top.u_core.data_rsp_id, top.u_core.dataram_core_rdata};
      if (top.u_core.if_rsp_valid && (!hs_i_pending || top.u_core.if_rsp_id != hs_i_id || top.u_core.if_rsp_error))
        $fatal(1, "Invalid instruction response before acceptance");
      if (top.u_core.data_rsp_valid && (!hs_d_pending || top.u_core.data_rsp_id != hs_d_id || top.u_core.data_rsp_error))
        $fatal(1, "Invalid data response before acceptance");

      if (top.u_core.if_rsp_valid && top.u_core.if_rsp_ready) begin
        if (!hs_i_pending || top.u_core.if_rsp_id != hs_i_id || top.u_core.if_rsp_error)
          $fatal(1, "Unexpected instruction response/ID/error");
        hs_i_pending <= 1'b0;
        hs_i_responses <= hs_i_responses + 1;
        if (top.u_core.if_request_killed || top.u_core.frontend_flush)
          hs_killed <= hs_killed + 1;
      end
      if (top.u_core.core_instrom_ren && top.u_core.if_req_ready) begin
        if (hs_i_pending && !(top.u_core.if_rsp_valid && top.u_core.if_rsp_ready))
          $fatal(1, "Multiple instruction requests outstanding");
        hs_i_pending <= 1'b1;
        hs_i_id <= top.u_core.if_req_id;
        hs_i_requests <= hs_i_requests + 1;
        if (top.u_core.if_rsp_valid && top.u_core.if_rsp_ready) hs_i_overlap <= hs_i_overlap + 1;
        if (top.u_core.if_offered_killed || top.u_core.frontend_flush)
          hs_held_killed <= hs_held_killed + 1;
      end
      if (top.u_core.data_req_valid && top.u_core.data_req_ready) begin
        if (hs_d_pending) $fatal(1, "Multiple data requests outstanding");
        hs_d_pending <= 1'b1;
        hs_d_id <= top.u_core.data_req_id;
        hs_d_requests <= hs_d_requests + 1;
      end
      if (top.u_core.data_rsp_valid && top.u_core.data_rsp_ready) begin
        if (!hs_d_pending || top.u_core.data_rsp_id != hs_d_id || top.u_core.data_rsp_error)
          $fatal(1, "Unexpected data response/ID/error");
        hs_d_pending <= 1'b0;
        hs_d_responses <= hs_d_responses + 1;
      end
      if (top.u_core.backend_if_start != (top.u_core.core_instrom_ren && top.u_core.if_req_ready) ||
          top.u_core.backend_data_start != (top.u_core.data_req_valid && top.u_core.data_req_ready))
        $fatal(1, "Backend access did not match exactly one accepted request");
      if (top.u_core.wb_consumed && top.u_core.wb_reg_rd_wen)
        $fatal(1, "WB instruction committed twice");
    end
  end

  final begin
    $display("[HANDSHAKE] i_req=%0d i_rsp=%0d d_req=%0d d_rsp=%0d killed=%0d",
             hs_i_requests, hs_i_responses, hs_d_requests, hs_d_responses, hs_killed);
    $display("[IF-COVERAGE] replace=%0d killed_offer=%0d", hs_i_overlap, hs_held_killed);
  end
