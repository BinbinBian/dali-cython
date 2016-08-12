from dali.tensor.tensor          cimport *
from dali.array.array            cimport *
from third_party.libcpp11.vector cimport vector
from ..array.dtype                      cimport *
from .layers                     cimport CStackedInputLayer, StackedInputLayer
import numpy                     as np
cimport third_party.modern_numpy as c_np

cdef extern from "dali/layers/lstm.h" nogil:

    cdef cppclass CLSTMState "LSTMState":
        CTensor memory
        CTensor hidden
        CLSTMState()
        CLSTMState(CTensor memory, CTensor hidden)

    cdef cppclass CLSTM "LSTM":
        vector[CTensor] Wcells_to_inputs
        vector[CTensor] Wcells_to_forgets
        CTensor Wco

        CStackedInputLayer input_layer
        vector[CStackedInputLayer] forget_layers
        CStackedInputLayer output_layer
        CStackedInputLayer cell_layer

        int hidden_size
        vector[int] input_sizes
        int num_children

        bint memory_feeds_gates
        bint backprop_through_gates

        CLSTM()
        CLSTM(int input_size, int hidden_size, bint memory_feeds_gates, DType, CDevice) except +
        CLSTM(int input_size, int hidden_size, int num_children, bint memory_feeds_gates, DType, CDevice) except +
        CLSTM(vector[int] input_sizes, int hidden_size, int num_children, bint memory_feeds_gates, DType, CDevice) except +
        CLSTM(const CLSTM&, bint copy_w, bint copy_dw) except +

        vector[CTensor] parameters()

        CTensor activate(CTensor) except+
        CLSTM shallow_copy()

        CLSTMState initial_states()
        CLSTMState activate(CTensor input_vector, CLSTMState previous_state) except +
        CLSTMState activate(CTensor input_vector, vector[CLSTMState] previous_children_states) except +
        CLSTMState activate(vector[CTensor] input_vectors, vector[CLSTMState] previous_children_states) except +
        CLSTMState activate_sequence(CLSTMState initial_state, vector[CTensor] sequence) except +

cdef class LSTMState:
    cdef CLSTMState o

    @staticmethod
    cdef LSTMState wrapc(CLSTMState o)

cdef class LSTM:
    cdef CLSTM o

    @staticmethod
    cdef LSTM wrapc(CLSTM o)