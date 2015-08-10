import dill as pickle
import numpy as np
import types

from os import makedirs, listdir
from os.path import join, exists

import inspect

def apply_recursively_on_type(x, f, target_type, list_callback=None):
    if type(x) == target_type:
        return f(x)
    elif type(x) == list or isinstance(x, types.GeneratorType):
        ret = [ apply_recursively_on_type(el, f, target_type, list_callback) for el in x]
        if list_callback and all(type(el) == target_type for el in x):
            ret = list_callback(ret)
        return ret
    elif type(x) == dict:
        res = {}
        for k,v in x.items():
            res[k] = apply_recursively_on_type(v, f, target_type, list_callback)
        return res
    else:
        return x


def median_smoothing(signal, window=10):
    res = []
    for i in range(window, len(signal)):
        actual_window = signal[i-window:i]
        res.append(np.median(actual_window))
    return res

def pickle_globals(directory, variables, caller_globals=None):
    if not exists(directory):
        makedirs(directory)

    if caller_globals is None:
        stack = inspect.stack()
        caller_globals = stack[1][0].f_globals
        del stack

    for var in variables:
        with open(join(directory, var + ".pkz"), "wb") as f:
            pickle.dump(caller_globals[var], f)

def unpickle_globals(directory, whitelist=None, extension='.pkz', caller_globals=None):
    assert exists(directory)

    if caller_globals is None:
        stack = inspect.stack()
        caller_globals = stack[1][0].f_globals
        del stack

    for file_name in listdir(directory):
        if file_name.endswith(extension):
            var_name = file_name[:-len(extension)]
            if whitelist is None or var_name in whitelist:
                with open(join(directory, file_name), "rb") as f:
                    caller_globals[var_name] = pickle.load(f)